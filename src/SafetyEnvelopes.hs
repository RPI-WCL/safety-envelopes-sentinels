module SafetyEnvelopes
    ( check
    ) where

import Data.Maybe (fromMaybe)

import MAlonzo.Code.Avionics.SafetyEnvelopes (consistencyenvelope)

check :: Int -> Double -> Double -> (Double, Bool)
check n mul x = fromMaybe (x, False) $ check_cf n mul x

check_all :: Double -> Double -> (Double, Bool)
check_all mul = consistencyenvelope (zip (concat means) (concat stds)) mul

check_cf :: Int -> Double -> Double -> Maybe (Double, Bool)
check_cf n mul x = do
  means_ <- means `at` n
  stds_ <- stds `at` n
  return $ consistencyenvelope (zip means_ stds_) mul x

at :: [a] -> Int -> Maybe a
xs `at` i
  | i < 0 = Nothing
  | otherwise = helper xs i
    where helper :: [a] -> Int -> Maybe a
          helper (x:_)  0 = Just x
          helper (_:xs) i = helper xs (i-1)
          helper []     i = Nothing

means =
  [[8.533698238451931, 7.993453039552186, 9.683179649326345, 9.744845127680092, 8.051139004651676, 8.149560517232478, 7.017645787179959, 7.7340565221218, 8.739007563323275, 8.476700050191917, 10.278168203684173, 299.1506153898162, 290.9946633961423, 242.73432158045267, 313.81402221777574, 418.2872152952427, 386.71400249187377, 290.3630126444733],
   [12.5445271581811, 13.565777174383294, 32.19475037689901, 15.565506335237481, 16.650693404199334, 19.198173580656228, 18.876073865202386, 21.799095786837057, 22.96200207907672, 23.700553619805294, 24.340687007851546, 593.5578147199934, 860.4903817801338, 930.260032234407, 1033.5643629118742, 1342.487413979741, 1200.962980823549, 778.7383192362004],
   [24.64356709322783, 27.3527806046669, 33.509511526069616, 36.73784861480099, 31.050598845964338, 42.3694197830037, 39.71780160248259, 41.07599987992727, 42.52657355899657, 59.412166087247925, 50.60543932469245, 73.83091216396375, 221.1570831922409, 1945.778781499523, 1644.2390525549974, 2116.899834353716, 3957.1905696275558, 1903.251827047725],
   [32.53500670372257, 39.30691053098001, 42.280790889781834, 48.21525176409407, 37.020215217272735, 48.900371473985864, 56.27572615599938, 61.39607664820808, 66.44151874595433, 88.40601194335945, 89.16186367689453, 103.6708063079908, 418.8374809546486, 2617.253999786739, 2225.7403175924005, 2194.7223520406246, 6200.175876650125, 3600.992008009996],
   [46.980404891518, 55.66038698057256, 59.879630116089125, 61.51219449170384, 52.04276341208401, 64.52332123366293, 90.50663712186078, 84.41773617915595, 108.13892020797311, 128.10654527702658, 144.50628663634296, 173.85761591585114, 643.7453530895231, 3838.5874906208846, 3102.9941970205814, 2765.46593981027, 7923.725238822606, 5929.404347972033],
   [70.9627087847754, 78.76259292809225, 84.25455448900348, 88.02711604503774, 74.03978968856357, 101.12570786851369, 146.30422921578622, 140.7041414120369, 151.9871125906275, 190.97920882043508, 216.94608149039794, 281.5998197200246, 863.7135023957918, 6267.906941847951, 5254.118945356741, 3864.35411890541, 9417.100127242338, 13108.578514359682],
   [95.04958818573263, 97.79296780922147, 108.04157275772998, 123.35593275341958, 119.53823587825646, 148.5922788964031, 183.22632990672471, 194.89602262552512, 214.60909096911186, 258.1946813291479, 301.7618864025257, 401.3046398031548, 1168.3128795339314, 1940.5629635104974, 7205.577043059304, 5827.642104027128, 9473.478932991973, 21026.66716039407],
   [140.5065575953273, 131.43103853093942, 140.96394403927735, 169.8454968908549, 168.95527764617515, 210.7144381916056, 267.0714404200702, 271.0674322244871, 272.68472597423477, 346.25292164113415, 467.5857775481026, 569.7233973363581, 1509.049862962627, 2512.6799820778037, 12134.470905889506, 8613.432629017043, 10668.01090006597, 25387.494380829467],
   [170.25794572313387, 164.52348627487717, 167.56036941332084, 200.88744840552383, 197.5088940677784, 268.9215844474161, 304.3873268909983, 331.0999005939044, 371.567827459627, 449.9632558518518, 621.0489640755926, 888.542553922981, 2151.9022267590212, 3333.416285848804, 3450.4557412261374, 8166.447448130102, 12661.973956878359],
   [202.9049149806951, 191.68336169347492, 223.6995054139292, 261.25396989015394, 280.6955659297601, 343.90360215130494, 466.17091871910895, 444.4097181095213, 474.89431305894794, 572.7655422938351, 724.9583922501641, 1149.0343399464052, 3015.02939644122, 4393.158499718567, 4700.503643628674, 4842.281214634965],
   [228.1365023621435, 234.89586393301772, 275.1376280528002, 335.7317717869369, 382.53027481816923, 442.5723931197217, 566.6606419050146, 571.7925287519012, 635.3676842864047, 671.2609152210305, 877.8037345928192, 1502.5760716766465, 3545.03482939005, 5379.323187154725],
   [258.2417089804815, 276.760165427074, 363.7868887837709, 443.42774430187796, 440.2417887230566, 554.1545921413522, 631.0025432168336, 724.1191887699874, 803.3374255638153, 848.2063220811795, 1061.366967154367, 1859.756020655698, 4571.121369899624],
   [286.50624578384475, 331.9169694555637, 404.3749751919012, 479.27508800345305, 531.4497845450823, 624.6187827947547, 754.9618136472353, 769.632208756508, 895.5802503744331, 985.2499647069498, 1114.670222605959, 2158.8699555112757],
   [334.38501514339663, 399.463268618592, 446.46991331029034, 566.658560652918, 583.7518171110187, 729.9145061286895, 812.3092466708811, 947.6381450496342, 1007.8820208176372],
   [404.14049858768146, 468.4091536603063, 560.7707948982558, 700.2163345191419, 653.7154001096463, 698.1921245065, 949.9034388914524]]

stds =
  [[0.8945776435168985, 0.8379456537866956, 1.0150785465155348, 1.0215459592992056, 0.843992547233838, 0.8543115581768607, 0.7356520664156178, 0.810754099701888, 0.9161031271484739, 0.8886065384292686, 1.0774504605770077, 31.359861880092957, 30.504800837046652, 25.44563738583848, 32.89692675168995, 43.84874785696323, 40.53906403427366, 30.438820584871237],
   [1.3150611879769238, 1.4220881512664234, 3.375623234954002, 1.631726089416571, 1.7454788231539313, 2.0125366808522958, 1.9787754356310352, 2.285187529690097, 2.4070897014209476, 2.484521015924421, 2.5516134529778673, 62.22683997807714, 90.20447147968247, 97.51828653713532, 108.34774887292146, 140.73181685753093, 125.896199582504, 81.63447502494843],
   [2.5833618148589985, 2.867368193295279, 3.5127723460911713, 3.8512059253258024, 3.2550055451187583, 4.441568772539375, 4.163591258141671, 4.305972637967263, 4.4580235820895675, 6.228160563925404, 5.304927478352143, 7.739675802169819, 23.183689281579987, 203.97409894108702, 172.36394458805097, 221.9124610218178, 414.8282886143897, 199.51688765021964],
   [3.4106133688261284, 4.120528502176787, 4.432263807161612, 5.054369807986651, 3.8807966244716328, 5.126191563656222, 5.8993606192754084, 6.436084988743293, 6.965017996159095, 9.267523478030517, 9.34679387095354, 10.867728506213284, 43.90628440082764, 274.3651052824444, 233.32223266809262, 230.07091962922019, 649.9611098652811, 377.49046720141763],
   [4.92508945456582, 5.834849077829499, 6.277212292594515, 6.448273965145434, 5.45559436752463, 6.763915994520089, 9.487789957965242, 8.84944065852193, 11.336118749266562, 13.429312595212355, 15.14846524243296, 18.225391293474736, 67.48321166175836, 402.39632866987466, 325.2852103543973, 289.9025408595348, 830.6405818999096, 621.5797442540503],
   [7.439003228993491, 8.256613047253579, 8.832333421065607, 9.22780754769899, 7.761516260206011, 10.60091797778092, 15.337072061207133, 14.749952546942371, 15.932699037620404, 20.020266982041626, 22.742297062703898, 29.519841820290345, 90.54227125913309, 657.0597279732301, 550.7870619040698, 405.0974001629597, 987.1953130444443, 1374.170016214716],
   [9.963975236692727, 10.251533944670975, 11.325890261601788, 12.93131435426051, 12.531216001631199, 15.576814301051526, 19.20748756425194, 20.430846457724588, 22.497277654692954, 27.06659859083349, 31.63339814044761, 42.068401831599914, 122.47311190464772, 203.42733785759103, 755.3550607422866, 610.9073544374662, 993.105401742089, 2204.212830158857],
   [14.729239896959447, 13.77778027934916, 14.777126604044376, 17.80479823861066, 17.711437008724474, 22.08900090278241, 27.996870259178745, 28.41578784282296, 28.58531211548445, 36.29741948328602, 49.016519511799814, 59.723500108807656, 158.19206308790612, 263.4017496010562, 1272.04530311421, 902.9390323766237, 1118.3197534584097, 2661.3579428069775],
   [17.848037355025927, 17.24685034740134, 17.565179150267927, 21.05883742915771, 20.704651569672286, 28.19085274385352, 31.908746252682445, 34.70893389594334, 38.951168104518445, 47.16927510726977, 65.1039022938264, 93.14508239130645, 225.58166731695653, 349.43833364613465, 361.7073432983125, 856.0928490394618, 1327.3449753585874],
   [21.270332891108655, 20.093969294352185, 23.450219745027617, 27.387004738594822, 29.42506956898617, 36.051133739826305, 48.86833346332782, 46.58729368656902, 49.78282304688788, 60.042554906693894, 75.99668767765773, 120.45227639848203, 316.0628066337128, 460.5308225461204, 492.74935368141416, 507.6121943628227],
   [23.915340943174872, 24.623886975933253, 28.842413862471297, 35.194521474760656, 40.100321589955044, 46.39449018047772, 59.40305614936422, 59.94049181227917, 66.60500301914804, 70.3676754864971, 92.01933569523675, 157.5137480863556, 371.62216665792084, 563.9096149824938],
   [27.071268272340127, 29.012458234897732, 38.135397810603116, 46.48416972688736, 46.150110503355165, 58.09162419717864, 66.14759983579945, 75.90878942992235, 84.21343614905551, 88.91665673709166, 111.26201165672501, 194.95639677486946, 479.1862113067307],
   [30.034179394490785, 34.79451924212446, 42.39022373560832, 50.241869680708525, 55.71134160757275, 65.47814303417422, 79.14219655133519, 80.67978264803658, 93.88282261291423, 103.28291271979674, 116.849696997458, 226.3123434886873],
   [35.05325202238769, 41.87533339580619, 46.80300811886175, 59.40226027767472, 61.19412359811125, 76.51629002895609, 85.15363381623892, 99.34029730613787, 105.65520412764931],
   [42.36568626668217, 49.102835205411914, 58.785054980682226, 73.40299121490882, 68.52837877309031, 73.1908298618019, 99.57749005049914]]