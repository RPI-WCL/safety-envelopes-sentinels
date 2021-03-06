module Avionics.SafetyEnvelopes where

open import Data.Bool using (Bool; true; false; _∧_; _∨_)
open import Data.List using (List; []; _∷_; any; map; foldl; length)
open import Data.List.Relation.Unary.Any as Any using (Any)
open import Data.List.Relation.Unary.All as All using (All)
open import Data.Maybe using (Maybe; just; nothing; is-just; _>>=_)
open import Data.Nat using (ℕ; zero; suc)
open import Data.Product using (_×_; proj₁; proj₂) renaming (_,_ to ⟨_,_⟩)
open import Function using (_∘_)
open import Relation.Binary.PropositionalEquality
    using (_≡_; _≢_; refl; cong; subst; sym; trans)
open import Relation.Unary using (_∈_)
open import Relation.Nullary using (yes; no; ¬_)
open import Relation.Nullary.Decidable using (fromWitnessFalse)

open import Avionics.Real
    using (ℝ; _+_; _-_; _*_; _÷_; _^_; _<ᵇ_; _≤ᵇ_; _≤_; _<_; _<?_; _≤?_; _≟_;
           1/_;
           0ℝ; 1ℝ; 2ℝ; 1/2; _^2; √_; fromℕ)
--open import Avionics.Product using (_×_; ⟨_,_⟩; proj₁; proj₂)
open import Avionics.Probability using (Dist; NormalDist; ND)

sum : List ℝ → ℝ
sum = foldl _+_ 0ℝ

inside : NormalDist → ℝ → ℝ → Bool
inside nd z x = ((μ - z * σ) <ᵇ x) ∧ (x <ᵇ (μ + z * σ))
  where open NormalDist nd using (μ; σ)

record Model : Set where
  field
    -- Angles of attack and airspeed available in the model
    SM : List (ℝ × ℝ)
    -- Map from angles of attack and airspeeds to Normal Distributions
    fM : List ((ℝ × ℝ) × (NormalDist × ℝ))
    -- Every pair of angle of attack and airspeed must be represented in the map fM
    .fMisMap₁ : All (λ ⟨α,v⟩ → Any (λ ⟨α,v⟩,ND → proj₁ ⟨α,v⟩,ND ≡ ⟨α,v⟩) fM ) SM
    .fMisMap₂ : All (λ ⟨α,v⟩,ND → Any (λ ⟨α,v⟩ → proj₁ ⟨α,v⟩,ND ≡ ⟨α,v⟩) SM ) fM
    .lenSM>0 : length SM ≢ 0
    --.lenfM>0 : length fM ≢ 0 -- this is the result of the bijection above and .lenSM>0

z-predictable' : List NormalDist → ℝ → ℝ → ℝ × Bool
z-predictable' nds z x = ⟨ x , any (λ nd → inside nd z x) nds ⟩

z-predictable : Model → ℝ → ℝ → ℝ × Bool
z-predictable M z x = z-predictable' (map (proj₁ ∘ proj₂) (Model.fM M)) z x

--

sample-z-predictable : List NormalDist → ℝ → ℝ → List ℝ → Maybe (ℝ × ℝ × Bool)
sample-z-predictable nds zμ zσ [] = nothing
sample-z-predictable nds zμ zσ (_ ∷ []) = nothing
sample-z-predictable nds zμ zσ xs@(_ ∷ _ ∷ _) = just ⟨ mean , ⟨ var_est , any inside' nds ⟩ ⟩
  where
    n = fromℕ (length xs)

    mean = (sum xs ÷ n)
    var_est = (sum (map (λ{x →(x - mean)^2}) xs) ÷ (n - 1ℝ))

    inside' : NormalDist → Bool
    inside' nd = ((μ - zμ * σ) <ᵇ mean) ∧ (mean <ᵇ (μ + zμ * σ))
              ∧ (σ^2 - zσ * std[σ^2] <ᵇ var) ∧ (var <ᵇ σ^2 + zσ * std[σ^2])
      where open NormalDist nd using (μ; σ)
            σ^2 = σ ^2
            --Var[σ^2] = 2 * (σ^2)^2 / n
            std[σ^2] = (√ 2ℝ) * (σ^2 ÷ (√ n))

            -- Notice that the estimated variance here is computed assuming `μ`
            -- it's the mean of the distribution. This is so that Cramer-Rao
            -- lower bound can be applied to it
            var = (sum (map (λ{x →(x - μ)^2}) xs) ÷ n)

nonneg-cf : ℝ → ℝ × Bool
nonneg-cf x = ⟨ x , 0ℝ ≤ᵇ x ⟩

data StallClasses : Set where
  Stall NoStall Uncertain : StallClasses


P[stall]f⟨_|stall⟩_ : ℝ → List (ℝ × ℝ × Dist ℝ) → ℝ
P[stall]f⟨ x |stall⟩ pbs = sum (map unpack pbs)
  where
    unpack : ℝ × ℝ × Dist ℝ → ℝ
    unpack ⟨ P[⟨α,v⟩] , ⟨ P[stall|⟨α,v⟩] , dist ⟩ ⟩ = pdf x * P[⟨α,v⟩] * P[stall|⟨α,v⟩]
      where open Dist dist using (pdf)

f⟨_⟩_ : ℝ → List (ℝ × ℝ × Dist ℝ) → ℝ
f⟨ x ⟩ pbs = sum (map unpack pbs)
  where
    unpack : ℝ × ℝ × Dist ℝ → ℝ
    unpack ⟨ P[⟨α,v⟩] , ⟨ _ , dist ⟩ ⟩ = pdf x * P[⟨α,v⟩]
      where open Dist dist using (pdf)

-- There should be a proof showing that the resulting value will always be in the interval [0,1]
P[_|X=_]_ : StallClasses → ℝ → List (ℝ × ℝ × Dist ℝ) → Maybe ℝ
P[ Stall |X= x ] pbs with f⟨ x ⟩ pbs ≟ 0ℝ
... | yes _ = nothing
... | no _  = just (((P[stall]f⟨ x |stall⟩ pbs) ÷ (f⟨ x ⟩ pbs)))
P[ NoStall |X= x ] pbs with f⟨ x ⟩ pbs ≟ 0ℝ
... | yes _ = nothing
... | no _  = just (1ℝ - ((P[stall]f⟨ x |stall⟩ pbs) ÷ (f⟨ x ⟩ pbs)))
P[ Uncertain |X= _ ] _ = nothing

postulate
  -- TODO: Find out how to prove this!
  -- It probably requires to prove that P[Stall|X=x] + P[NoStall|X=x] ≡ 1
  Stall≡1-NoStall : ∀ {x pbs p}
                  → P[ Stall |X= x ] pbs ≡ just p
                  → P[ NoStall |X= x ] pbs ≡ just (1ℝ - p)
  NoStall≡1-Stall : ∀ {x pbs p}
                  → P[ NoStall |X= x ] pbs ≡ just p
                  → P[ Stall |X= x ] pbs ≡ just (1ℝ - p)

  -- Main assumptions
  --   * 0.5 < τ ≤ 1
  --   * 0 ≤ p ≤ 1
  -- Of course, these assumptions are never explicit in the code. But note
  -- that, only the first assumption can be broken by an user bad input. The
  -- second assumption stems for probability theory, yet not proven but
  -- should be true
  ≤p→¬≤1-p : ∀ {τ p}
           -- This first line are the assumptions. From them, the rest should follow
           → 1/2 < τ → τ ≤ 1ℝ   -- 0.5 < τ ≤ 1
           → 0ℝ ≤ p → p ≤ 1ℝ  -- 0 ≤ p ≤ 1
           → τ ≤ p
           → ¬ τ ≤ (1ℝ - p)
  ≤1-p→¬≤p : ∀ {τ p}
           → 1/2 < τ → τ ≤ 1ℝ  -- 0.5 < τ ≤ 1
           → 0ℝ ≤ p → p ≤ 1ℝ   -- 0 ≤ p ≤ 1
           → τ ≤ (1ℝ - p)
           → ¬ τ ≤ p


classify'' : List (ℝ × ℝ × Dist ℝ) → ℝ → ℝ → StallClasses
classify'' pbs τ x with P[ Stall |X= x ] pbs
...   | nothing = Uncertain
...   | just p with τ ≤? p | τ ≤? (1ℝ - p)
...            | yes _ | no  _ = Stall
...            | no _  | yes _ = NoStall
...            | _     | _     = Uncertain -- the only missing case is `no _ | no _`, `yes _ | yes _` is not possible

M→pbs : Model → List (ℝ × ℝ × Dist ℝ)
M→pbs M = map convert (Model.fM M)
  where 
    n = fromℕ (length (Model.fM M))

    convert : (ℝ × ℝ) × (NormalDist × ℝ) → ℝ × ℝ × Dist ℝ
    convert ⟨ _ , ⟨ nd , P[stall|c] ⟩ ⟩ = ⟨ 1/ n , ⟨ P[stall|c] , dist ⟩ ⟩
      where open NormalDist nd using (dist)

classify : Model → ℝ → ℝ → StallClasses
classify M = classify'' (M→pbs M)

no-uncertain : StallClasses → Bool
no-uncertain Uncertain = false
no-uncertain _ = true

τ-confident : Model → ℝ → ℝ → Bool
τ-confident M τ = no-uncertain ∘ classify M τ

safety-envelope : Model → ℝ → ℝ → ℝ → Bool
safety-envelope M z τ x = proj₂ (z-predictable M z x)
                          ∧ τ-confident M τ x
