unit URandomHashTests;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  Classes, SysUtils, {$IFDEF FPC}fpcunit,testregistry,{$ELSE}TestFramework,{$ENDIF FPC}
  UUnitTests, URandomHash, HlpIHash;

type

  { TRandomHashTest }

  TRandomHashTest = class(TPascalCoinUnitTest)
  private
    procedure TestSubHash(AHasher : IHash; const ATestData : array of TTestItem<Integer, String>);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRandomHash_Standard;
    procedure TestRandomHash;
    procedure TestSHA2_256;
    procedure TestSHA2_384;
    procedure TestSHA3_256;
    procedure TestSHA3_384;
    procedure TestSHA3_512;
    procedure TestRIPEMD160;
    procedure TestRIPEMD256;
    procedure TestRIPEMD320;
    procedure TestBLAKE2B;
    procedure TestBLAKE2S;
    procedure TestTIGER2_5_192;
    procedure TestSNEFRU_8_256;
    procedure TestGRINDAHL512;
    procedure TestHAVAL_5_256;
    procedure TestMD5;
    procedure TestRADIOGATUN32;
    procedure TestWHIRLPOOL;
    procedure TestMURMUR3_32;
  end;

implementation

uses variants, UCommon, HlpHashFactory;

const

  { General purpose byte array for testing }

  DATA_HASH_INPUT : String = '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855000000006d68295b00000000';

  { RandomHash Official Values }

  DATA_RANDOMHASH_STANDARD : array[1..3] of TTestItem<String, String> = (
    (Input: '0x0';                                         Expected: '0xa09234cf9fae2f57fc57ac7dface74b94d82f576ddc7ba386bce5f110f8c5b0f'),
    (Input: 'The quick brown fox jumps over the lazy dog'; Expected: '0xe36824b6f0c99752c8f183fefd1fe458d8dfc2784421f307912bcd0955249a70'),
    (Input: '0x000102030405060708090a0b0c0d0e0f';          Expected: '0xbf98bbded77fac7e9117525a4cc781457da484c948df9d0407ca6cae6fe620ed')
  );

  {  Hash Test Data }

  DATA_RANDOMHASH : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0x8a803cfad1d20225590fdd0dcfb8e20fc65bb413051671a7113f6ec22db8a5b3'),
    (Input: 31;  Expected: '0x4b553d4d2c72e6d47143f04316ff5b98aca8f8bb4d7bde67588fe09e76a5cc82'),
    (Input: 32;  Expected: '0xf244bbb0ba004762b5642c80d71a528e8515a4aa81f84f15dbca7a564da670dc'),
    (Input: 33;  Expected: '0x5bf6ac80f94c54df7d3725224d7d0c315f29b3431db6d2841fdd8fecada884cb'),
    (Input: 34;  Expected: '0x9bad6a1d08fb04bacd096985153b954ef2b7bc209768a3626fab47a559cab18d'),
    (Input: 63;  Expected: '0xa021970a0b9a9c4c3edad278f0124b0d0da301dc8e43c17fe8b54f0b5763967d'),
    (Input: 64;  Expected: '0x13315a71b8d56c4767fb42f9a3ae377f33a533b31614777e14946f8168ec2cfa'),
    (Input: 65;  Expected: '0x8f371e8a2d055de9bf6362ff7b76be8fc750d57de2bb6843b3ea8bc5d6cef0c0'),
    (Input: 100; Expected: '0xf485559639f23fc3d25893bfca39029f64d0e4f1c4f22853a1392d2589be7452'),
    (Input: 117; Expected: '0xef46eb14c91119b8d94aeefaa2f3ff5e7f70f63a444e2bfc78f75c2c9fa15a7b'),
    (Input: 127; Expected: '0x360fae4011a948a2682a4a10905c2d62ddddd8f4816c85f3548b4d5233aa059c'),
    (Input: 128; Expected: '0x1eda18aceab0130029f72a0430de9a4683c247f423555e11791c4775c033a5d3'),
    (Input: 129; Expected: '0x26f1d096cc186f1749130118f1fd4b6b59a05146a4162bee040d94fbeefffe4b'),
    (Input: 178; Expected: '0x32bc335af31dd40f20499799fb942a65061f1bfbe4a74b19981408a8151fc62a'),
    (Input: 199; Expected: '0x7d58ca691eb1f5c1ae2b22214e11e9ce5d2cc54d1ba3df10ed43e865478cfc39'),
    (Input: 200; Expected: '0x318dee64b78c0259375ea92e1a25d7e85d32f3442a0694130dc9f860a09ea325')
  );

  DATA_SHA2_256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0x0fd3f87ae8963c1ac8aabc0706d2ad5a66c2d88b50f57821b864b093263a7a05'),
    (Input: 31;  Expected: '0x209ef563d4ac7d51968cced180be0145dbd4d4c9688bdbdd8fcdb171029bff35'),
    (Input: 32;  Expected: '0xa910d364190b6aed1c0a4198688a1a5ac4b37205c542d665be0f5aa558ad483e'),
    (Input: 33;  Expected: '0x8f2d5d44ca1a2f534253a600c4e95f315133f775127a11bcb22db928efbd638d'),
    (Input: 34;  Expected: '0xda8f41e9f2ac0effa4815a50f599b0791f210cb85f056672404639c960f56fe8'),
    (Input: 63;  Expected: '0xb06a88f708c40510cc132a5108c6f26a9a3f7f6d42e0143baaacaf96aec16952'),
    (Input: 64;  Expected: '0x3725408cbe6e81f8a05bd2f1b4618a356235b7262eb809608bc4e3dc38e4fa1f'),
    (Input: 65;  Expected: '0xaf29a07c4c9ca57aa087a3c6134573615ec8b54706c75361cfd23fba38d8a5d0'),
    (Input: 100; Expected: '0x30cb592bdaf02c26fcba00c055059d9c3cf74f10a7eb49e2fcd4926c86c85e00'),
    (Input: 117; Expected: '0x1e34859b3591e50f8522d707a554725591603b95725d8d16f9dc728f901091d4'),
    (Input: 127; Expected: '0x6b3e56f2349c09aa0a814a0c5a9dfb72e13b79c57d3dd5bf802ab00c5040164b'),
    (Input: 128; Expected: '0x75b01600de565f4138151f345028a91a8471385509dfe27e2d07096b4c82136b'),
    (Input: 129; Expected: '0x5536bf5cdf0739e4ff259eb79a4276a009717e371057a3b8afe4ba79a03a884a'),
    (Input: 178; Expected: '0xad69c11f5d88dc4b047174218e843fdb29dbfb8dd2697f017bc8cd98a6a7b7fd'),
    (Input: 199; Expected: '0xcafebf56cdeaec6505b97a0f52369a79fa441d4d2e5a034d16ab0df00172b907'),
    (Input: 200; Expected: '0xd20e764994f9a21ca01a3e9247bc70618f39663773c3a7a839d8a2e1072f182d')
  );

  DATA_SHA2_384 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0x86b2d0189776966214f3469254c4a2e9d4fadbb81aab5d9ef8d67f085301a5128758c8f3b9b89d8d4460c684fe181a58'),
    (Input: 31;  Expected: '0xf19c9457db4e320f0a795dd911f46e4def8e57f567b0e058eba7ea7de7277e0e0cf9467d567f3913af7bd3812a999901'),
    (Input: 32;  Expected: '0x60e13c214f9ecc37ab48c67beda727612a635d9e67114c83b34ed44753a65d00a424fbc812f1ec16f93079d7ae97a939'),
    (Input: 33;  Expected: '0xdcc50f12c899f09c44901c549aae1d3d7341b2c6b78f2e566c671631d8df1e74ebf5b74f5230b92401ba9b74e75a4e67'),
    (Input: 34;  Expected: '0xf8a0491ef325a3af1ed02eac4e9bfd7ef645a1312318e0b5189300850ead5016194c39af296643dd5230c3b5cfa15479'),
    (Input: 63;  Expected: '0x2adbfe51413f5d3458581dc9b9ce713b6e96ff6208fa4716cd012710e6a2d834681d32b1915e661ebfcf8dedecc08c85'),
    (Input: 64;  Expected: '0x483f8d2065879e98c9640230d85cfffdcbf99543d7a2f24c045cf08ef8f53cb5472c93c1cd3655f35903ac91926ed2b8'),
    (Input: 65;  Expected: '0xc4397852b5944238dc167821e2f51e80ff736c0050b1abbd0400c8db1eeb4dc17e1fdc0ed9a0d61d2e2bc29ebbb583b9'),
    (Input: 100; Expected: '0x5526d6e720647cc23e1ab86a51c8e8601579b6952e5d610c4b450e41292e6acb073439b91fcdd75041f475530c033323'),
    (Input: 117; Expected: '0x7ade74e0a89e7ad77e76e9a35c04f67c933d8f4cab485d1628b0ced9ccc17f447ba38f81ebac28a4618abc006af4e5b4'),
    (Input: 127; Expected: '0x6e23e9d0dc3ee1ccb08f1f9568e8fc5d8d85b8b5a01afe63946894b39d68691330a63bbeaccc4fd6bac141c452feaa0e'),
    (Input: 128; Expected: '0x3b9d1126768bc0e16c6484a0025f492893a92927eb42cc645c23c22a6a5252bcb7b82ac748f0a99a49ce2ccdaafa723a'),
    (Input: 129; Expected: '0x2703c12554db5b80ef25b7d2dc4f0233b7b7064e69d57eff39b12aa77ad3c8b2e5d8014506179fc76399da952b2ed985'),
    (Input: 178; Expected: '0xc21fe026e7ba3c8e845512d39c592beddf903e6df81fb8ec0637464c279618b1f10a91b5291f1ab698d9354b61a3b2d6'),
    (Input: 199; Expected: '0x83843225d4dbfd455676885ea3b923ba2e0fa536a53c713365b5335623897840588d30260a4ed4d392c18efb6c96d946'),
    (Input: 200; Expected: '0xccfe1529f08bad44c42cf6bb96497f3474fe69631a33b58b4a28833e30dc7a404d63f5573dd81654e0430d92034b2b8b')
  );

  DATA_SHA2_512 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0xf729f844e23dadbfcb53c046407f03e790a7a9ec6004c570feea461f76b066353dfc5cca95629360d5ea310719bf6f0251a56e9c515b62b863206d6ff64b6784'),
    (Input: 31;  Expected: '0x526be8f0afbc7ffe77f62456f8d47b2e60bdad5ff1955841d9bcf82d9a2c71a9a2bdf4288d025154ff43ba65b4d4adb97ac24f47c27a28af7af0b2d831c9c7a2'),
    (Input: 32;  Expected: '0x3bbcc5f450e9b6708c22ed0ba40b5265d3b32130b9ffdcd06bfc61c49452aaabc8bf08df544f55935952c80d0e266f27f3f66ab4aa1b2f3e7b58ee0708200d79'),
    (Input: 33;  Expected: '0x10279e84bf5f4debae99ebb1c2186a3b5a510da642c99cb77ab981f39fbf55d20ef70fcb19880b86929dd7db3a4b2259b4b86d82a38b200933d550c42d729a57'),
    (Input: 34;  Expected: '0xb5c4f53ee9d151543fdb42640650e4ff930d2f145ce1986d6a8b3b1860a0136ec889e4f02675a99e0118430c9c8357f974ee99d0e52b62b92016ac2c6833af5b'),
    (Input: 63;  Expected: '0xa35de82665a3c12424e5a11acc356b329a56b15bee61c2332ec04fee142ad7699f9834800e127c0146827d8b84ad1ce0b57f2c5ed30afc0768e098a5d621dd97'),
    (Input: 64;  Expected: '0x6dd15a36cb5ae97d7ba0c74e19adea2bb4c243839f58aeef83cd8527e87c43069d0a02804dbcb281636b8712f6e546f31946318a709019ed11f3816642eba77b'),
    (Input: 65;  Expected: '0xa2433136dc3bd4f0e2d4d14b6033e1002f675c4ce842d7baeee78b95193030c647af66f0e54ff94ae3b60e46a88314a4a145f30267f3fd0990c6ebc2970b9fbf'),
    (Input: 117; Expected: '0xb4647f67deb7347a18d43d87a4143853855fd81602baab1edd8a08b32a74268adb12fc03b6d1a05d81e67dc75fa93386749dc1d40d988a685ed1550a5849b527'),
    (Input: 100; Expected: '0xa55acfa8808e502b5f02e23f6f824b56fbf6e8bba3f032d7ffd5b254200de521299a4e8f593c453c1483773cc78332d54f1016af2cbddac68ae7fef7aa399219'),
    (Input: 127; Expected: '0xd33bc6775743bd1110f51b84c0ebbdc57c622890b20d53b754ad9a1937e2761a1747d9adcdc2ec685549e418eb6ec3943c1e88d8e4a698389542547256522fe7'),
    (Input: 128; Expected: '0xf03557fc390333279816513d69a4e389ab51df3bf1a06b666c816c18f98c8dedaf338eea98e3063cd728ebcafe7d59dd19eca2bef4327a3421eb1e921af5d223'),
    (Input: 129; Expected: '0x5af2f48f25c994054c624afd99c5c9a59e91c492facdb65068cc1a15497f65ba0f6c5d15dc2f176f10ea6130c2894339a02fb99696b39b6c634066acc590427c'),
    (Input: 178; Expected: '0x8dc7dbc6d4b1ccd92948804c6474e5f94acaf59f4d908f86603abd3c7d96f18dc1d1723a22cef7b6e0ef9a6c1c33f390c4c85a9e1fd4c4fd4db3c867564f1d81'),
    (Input: 199; Expected: '0xf239e971dfa284808c7e95a9726e1f42942e431e2c942e84d020c580a7a4a8c1a7ca35af44f2efafee6d3d929c01c30f0588c01e8e6813649fb86b22f0369cb1'),
    (Input: 200; Expected: '0x5a9aee4aed39dd405980b29984dccc6b520b685c6beb6e42c3450b858e1cc45de9d235849fa743738a06514b30522180d06f98185a49919191e86374a79df3b9')
  );

  DATA_SHA3_256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0x84b6a1cf6df74b3a54da73cf2ae3bca8426fba94908199bba45ba1ccc8f680d8'),
    (Input: 31;  Expected: '0x49128a80ce9b14b46c310adcdfc0be99266ecd0728b4a12a7fdaa000d49c4106'),
    (Input: 32;  Expected: '0x60c394688e6a2eba3d14edcebf6b13c95eea80a458bf3f557e55df0dd710bebe'),
    (Input: 33;  Expected: '0xfeb0146e6af5c99e7dc931f28fa2c965c1e16a9360bb7fc5eacbd6658115b114'),
    (Input: 34;  Expected: '0xc247d6b3649e736004601810655ba1e7041c40a73ee5fd5d408e891a90f38dbb'),
    (Input: 63;  Expected: '0xd3e6fd4abf153070e11446c6dd1cfe748064239a9f680437a4b1d51c5c64fa2c'),
    (Input: 64;  Expected: '0xc5d9eea9c7d04746dde6e94cee94105a5d1f173809849c2d2953e31b3af5d556'),
    (Input: 65;  Expected: '0x81bd225df0d6dd4ed5347dbf688b4940b9a0f085db9a5efd8fa4dddf5bea2e9d'),
    (Input: 100; Expected: '0x5746f720dab78746407d4c594fda4a2539949183a0208553c8aee1d578b72898'),
    (Input: 127; Expected: '0x4230dbf66b2e324d321fcbd6ffbfeb0156e3070af672dc0c743b5001d6e530ac'),
    (Input: 117; Expected: '0xade65df24b483b5d51e8620dd05966dd89b96c90b69322c19d67c3a968f5514d'),
    (Input: 128; Expected: '0xc19c584bb6969ba83731d2f21025d556b9cf08a9e598cc97cdc5f021675e7a90'),
    (Input: 129; Expected: '0x82ea34a1f09ebaf85ad11efa05f81e9e7a8d6fbb62e04cfed2e5f26c4d1f09b5'),
    (Input: 178; Expected: '0x471ea99294ac57486166be9a3e3da3cbf588adc0c6606c290dddd513632931ac'),
    (Input: 199; Expected: '0xaf6df45fdc24388fba66baa4484ace35cdd01aa6a0f9a635f564c1ba5b1fefd3'),
    (Input: 200; Expected: '0xcd31079dc52963c7753ff9b8640ce60404fd44fe4464af475229aa704cb5de4f')
  );

  DATA_SHA3_384 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0xee2621cc2dc6f234c8976a1ac76a1eb8724213c67af5a704ba56a7bc92f09e146e1a1d7d0a5a4ae5405e8b9295fdf216'),
    (Input: 31;  Expected: '0xcac5638f7c264b72d01942b8109667b44142293cd1ad7bae06bcca65d82a5f72daf27070b17702415e9c3d501658ce57'),
    (Input: 32;  Expected: '0x509a74fbecb9d7cb23838a31bcd8447d73ae0893d2a60c53d6327467a2861e07b39ce800c01329ae2e06d1b3ecc905e3'),
    (Input: 33;  Expected: '0xcd6c73588fce7db1f3d59bdef9f544b6f08b2c50ec0b01dd012700d4274b80f4d0ff20ca774b27f04b31ef9f19bf0cc9'),
    (Input: 34;  Expected: '0xad76006715dd48f0138420ae2c3bd7d5e64ba735a307323c00192acbe837cec5cbe04312a1602ea757de41f18d0fde7f'),
    (Input: 63;  Expected: '0xddc1e64c8420ff5579eceac10844684d08cb769cf578925e59d98c79f5be736524ff44738a16543bba47d70b1ebcc36e'),
    (Input: 64;  Expected: '0xf29ec08d00ae2072137288e31990f2858629e23d2365a84a079cc5986dbcff1b16a19216aceb079e240e89626644bb3e'),
    (Input: 65;  Expected: '0x9a0bd293ed9ea460387266b65773bd73cd8c5c6ccadc0d1b901f35d1e82571a10b63bb90beeac3e1a0fc29786da0beb1'),
    (Input: 100; Expected: '0xaddb1229b53c3a35d1f974cfe7a1c3a6f6803996d72cbc13bf50376b85105b86b1fdeacdbe51525928e39e38ff23b1fc'),
    (Input: 117; Expected: '0x5c142da18a1e2b0f66f396e07cc102106227638a93d9cc5230b2c8ade550fab096049acb53fb5b357039983b77193460'),
    (Input: 127; Expected: '0xd3a0c04b1350044d29a099cb5d95175539e93e1144f471d27bbcae555864a3e7c87bbaf7107e8335206aebb2067c6e1d'),
    (Input: 128; Expected: '0x7538b4cc1d1fc9eb921f5bea8dda949b43e1f2e8fb7dbfd2f1e7b01f843dc5914fe7983cc29f53ea52c91da5e0e38a7c'),
    (Input: 129; Expected: '0x699fc858bf267ab42444dc5888f53e55c8bd7f195cda1bee192d9471fced05a25370f98d1e8a20127e57422fb226e499'),
    (Input: 178; Expected: '0x03c546e8f629538bdfe523e4776b9c4fce59b2c523a57482fcf212d617e63a7677b98ded0878b317e1514de278c58aec'),
    (Input: 199; Expected: '0xa2e0626bec9c34d571ec7079d0186b0235c45cc2faa165ca619c0ebd290f0292e7c565ee77fce106af58e0d30e7b673b'),
    (Input: 200; Expected: '0xaf0f60050d97927fa2becfd3b7938e31c20ff3576bc3adde5d51428e91de10102e3c49c24ae7e515838952e53709a67a')
  );

  DATA_SHA3_512 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0x36b8e099d4afb54a9aadb5c76154be673a96967a73e462fb401c21282a2c4554b832f323415c047156e3452e77070a085d14543b123b473ed93d03248514898c'),
    (Input: 31;  Expected: '0xdfc10d8ec28d43efe3cbba1c1e1edcb6f71c14d9057941afc590469350402e8fe1298de2ba20eaa8280dea009668d5dde5f7001b65fb9237284c8b60e6bf4e8f'),
    (Input: 32;  Expected: '0xe4290dafe0838e10c8752074731d7fdb76c4d5d632f75f2c508b357d344c622b8e5aa9ba1d58f4c859bb49b4b81a25c1faecbc08317ceafc00e1c3a9945295a4'),
    (Input: 33;  Expected: '0xdde23aa602cca8efcfa9b026cf067ada1b8bc5487b4dc029b31621294d5be3954e402ddfb4e5f9a0401648e6e649a0f05f647e61457289f705ee167c86f6c3db'),
    (Input: 34;  Expected: '0xa54f15ec275b53cb618ca462bb0de1776e1038f2cbc40df2da6a7e5e1333ba475fcead9e0c55e357547feca9a973f781bc9e601c7570a0f510414e27167be834'),
    (Input: 63;  Expected: '0x6971211bc158034f3420850303953d8845f9657871af4d35d71f75eb086e69c07f4e63eb173962d53279400688ae3637d2fd742255b93e3ab6bbe1b203243586'),
    (Input: 64;  Expected: '0xdec734f489aefcd5ad355134ef6fd1ebb18c8f741d16e0fedb201dd801905a7f39c2824b67b2b995679c8266530b527e2dd2af59f044cc5d034d93bc7c35efdd'),
    (Input: 65;  Expected: '0x40b460c3f18d2c0aa076db67af63c3d22a6c3d29853ca642204d3ff5b0649b394f2e10beaf78be0929cb499b24323462ad7242a3e3e9c7b7a89a58da4358d1c5'),
    (Input: 100; Expected: '0x480d6ea46a25eeb45a2eaa1a23304d68dba624635772d26a21fe8fe56376de8d298bcb5f5d48e59aa6193a55170ae5a1d15f4f8dfe7fdef7706c0686eb39862f'),
    (Input: 117; Expected: '0x5b7e1c31bf4358a77f1afb7f2c181cde1bf87b3d9e94fed09d82a996364998ee3e46b9e7ab94337ad967878741475b2d11061de00d06e1db3026e2859ca2af32'),
    (Input: 127; Expected: '0x73b63d13c3e4e9dcd9fcce0adaeba4423ec201aa7e13e33faba2b6fbc35efd76302148fc964f7647b24d770ae897c9d5ca0211e4b1e27a81fb769ecbfefb1511'),
    (Input: 128; Expected: '0xd5ec5de877ef0a39eefe294f6183b63adb91d2a0ba1ec1fd576db515ed78f8220442c2347bdeb8a0f77cdc46d97e5b96d4189fec1f5cd2e8b5de3d467684ad73'),
    (Input: 129; Expected: '0x461f2ef3ddb3101d2ae5b1edea9178bc431225a9e5bec7c04e446a70db25f2e8e9b24547733667f0794286a330297d11215f21da7b5eea03adf063193f5f49bf'),
    (Input: 178; Expected: '0x3f71cc9ed5acf47e4b994fb36bdc306c7e777a400532e0c0ec7e2ac1796c4471d39a09d7e32473e7bf804e4b342813a87f8f11c85da3b08f50cfe8af3f690d12'),
    (Input: 199; Expected: '0xe2e4d8eadf49edf7c0b81c97e0c115064a6788eda531df390b88d09586dd2f33f551c6fe4f930caaf3e6d24e7f3dce49c9ecfedb5ceeef796c1afa1776157736'),
    (Input: 200; Expected: '0xd62ed867af9fee338bc1cc712fdbc0da15afa40b4a5dcc3e76d74f1770c5a7ca88638f0cc8bce685cae8d68a2aa8717c84bc3e146100aff25c3326355b1735aa')
  );

  DATA_RIPEMD160 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0x734191cffedbbe96f14865d2eebe3650e54c6de6'),
    (Input: 31;  Expected: '0xf5c19350c4a7a79f1597b7172ff52205864c92e7'),
    (Input: 32;  Expected: '0x29c74325055e81d14d7165c28599e311c9b63c6a'),
    (Input: 33;  Expected: '0x1f54c3702f8dff024a6fae7ceb017a64f71b15a6'),
    (Input: 34;  Expected: '0x1068b29dd5bd6aec7cf04ffc1ef671cf83e7f239'),
    (Input: 63;  Expected: '0x5de126808d8b2656c8f91796eb2dd86a9fe65ad1'),
    (Input: 64;  Expected: '0xbf4c1c78a8e75584c6697fc2f1706e0c41c9df59'),
    (Input: 65;  Expected: '0x79123df7d67e2a3c3cdf3f1529deac143d44ca8c'),
    (Input: 100; Expected: '0xef7cdf0a7ded768b4675a743ac7ab64c3bc5fad3'),
    (Input: 117; Expected: '0xfb82dbfbb359e2f5fd3bc0a00a9bb7e873bda70d'),
    (Input: 127; Expected: '0x67073f8cb7f372f93bd57f289cf3829d801e78d6'),
    (Input: 128; Expected: '0xc923752f5fbb9721a48c5f1dbcfbc70865577869'),
    (Input: 129; Expected: '0x6ada1e777ecaacc07922cf839e1259d1f2b8afce'),
    (Input: 178; Expected: '0xabc2c368a457d10bc300954a4036b3a33eae7128'),
    (Input: 199; Expected: '0x31ed25a6a35ba860abc0804c6e8c3e3e6174099d'),
    (Input: 200; Expected: '0x1105e599abaea1b0f8d51c3878729ad0ca619a4e')
  );

  DATA_RIPEMD256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
    (Input: 17;  Expected: '0xb242099231d61f0d6c83044d360524b499a434d0ff12407296d1061e017bd023'),
    (Input: 31;  Expected: '0xe71778fbcc7b32156c66e244a6a07d10e463bb20cc35ed98c8cf35191ec013d3'),
    (Input: 32;  Expected: '0xd538e7bdd392ee4ec094a2a50cb6edec45537a87fd8f4a72a7fc573cd5ce43c7'),
    (Input: 33;  Expected: '0x7e1bbb5611223834cb1cee497b700c70cc27bbb042c2431fccd4ec67965567ee'),
    (Input: 34;  Expected: '0xa73d52f35585f3d4dd34850bf3e8de4697ad1f94cba71321d6784785f29ed905'),
    (Input: 63;  Expected: '0x48d647a2e1dc581b675daf26f0d08a11fff402a42c47d132f52133bb8a6895f4'),
    (Input: 64;  Expected: '0x2cefa11f6ea8dddd1d0c935b4f04f36c1631b1589eea6082ed53b3e9b54cfc72'),
    (Input: 65;  Expected: '0x5a2a91bab4ca44664ef1d16fb8f8cde48ba2dca1cc0c0faa636812b86b98fe3f'),
    (Input: 100; Expected: '0xa5fbe1faca66cc5d5f5dcea2550811254f221fb8761c4b5a3caf31f2f0534ad0'),
    (Input: 117; Expected: '0xf8cace5bd4fc6711706e6c3cfe9713234d40e4fafeb37b5dbe97c13c37f6ebc9'),
    (Input: 127; Expected: '0xd14265c897b77caa18c77c77c7f46f1a07faca209a16d997af794c15b145bb05'),
    (Input: 128; Expected: '0xb286ca27b0ae4f6c18886879f9713cd959fff512535bcd379943c95dcde7773f'),
    (Input: 129; Expected: '0xccfc63b15e2e810a36f3d26ed3b1bd49f456d1af97c3d46c0683833d37ce359f'),
    (Input: 178; Expected: '0xe6178a33180fdcad7cc503f5ed90b66610db900dee7326696cb4e10d1234caa7'),
    (Input: 199; Expected: '0x2a1c9d07ce2174a6a09a246c6edbdc4f0fd0514f0179984cb44c06b8b3c573b1'),
    (Input: 200; Expected: '0x29a962414ab1f46a2013178f831d66559a46d709fd3604b4b435ec4d8b536619')
  );

 DATA_RIPEMD320 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x3d9cd1561f939f3aa80ee5339fa11140e68f3dbcfdd928d4d31f6932a268bba329595cc1e347d06e'),
   (Input: 31;  Expected: '0x62dabb157501ee8aee1e7364942774f5741ed806f87f31d3754e956cda45c3423d31d5675cd7fcdd'),
   (Input: 32;  Expected: '0x286cbc2d0bd027673fdb6165c0281f3beabeafa2936d0d2b651010b473faa68fbad54c663c9d0fa2'),
   (Input: 33;  Expected: '0x921c28a7318df3bfca84091eb48ae54808fe79e9a24d716b641c61108272114a7c3e21614b316eb3'),
   (Input: 34;  Expected: '0xd569a0217a6bbbbd99e6f54899f14078adccc06b56be014bf3f25493763c7f6ebdb76fb0d187d0ba'),
   (Input: 63;  Expected: '0xffac8eacef53c8e9c9b9628ae080dbf8b50d9ccef6beaf0fc318f0921aeaa4624e478b48dff801fa'),
   (Input: 64;  Expected: '0x47f9c63000e89707be545cdf37e3697128b6ca013ea59ce576437125a35b94a1fc12b4568c2b42f7'),
   (Input: 65;  Expected: '0x0047b303eeff27dd6d3fd9ad838cb3eaac2d06b9f909729d449052bfb648c522e17f23beef18e14f'),
   (Input: 100; Expected: '0xd9eaaa5d3dbe16e6d2d06b1fdae8f5a6893303f82cf7ec838ee1b94a37ba2ecb8ccb008c149586bf'),
   (Input: 117; Expected: '0xdeff952e2a54873158c0cb880eb8c813f03716649006b9026dd9ba1556b9be4058ac4091c36693ac'),
   (Input: 127; Expected: '0xd5d5fbe5fb496f65ecc8f65b114bc498bad886b826e593fe0c66b0b03b868002be71c3219a992b61'),
   (Input: 128; Expected: '0x39bb7f49c9be805d4ff51210d6e64fc5b48a87ad4795e1c17deef630d4ab5f93bcee15b999fd81de'),
   (Input: 129; Expected: '0x1d18806ff98659458e4095e0acac282c1af2815cf5967402dad2c688afa4c10b16b6d1996415bf86'),
   (Input: 178; Expected: '0x957de878669f2a162f50a2c8bb07ae835b857985ef68f6c77d590b89861358698ed10fe59503b454'),
   (Input: 199; Expected: '0x527b23083ca9c12fe6f3e9936310f7b71c594113efaaeb58c195b657406a45a70f6d918e714ba450'),
   (Input: 200; Expected: '0xc56063dd1fb318af5a0910ed3993c3ea3f746be8ef65661af0fb4c7451f44dfcabfe7e5db469d9b3')
 );

 DATA_BLAKE2B : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x8f8a1cf77aad3d0421db8ae7b2a4752b811059d3a3a5cc3b00454ecd918f39936e2f8e23c5a96c6f4519f76e73981da24d2f8c4d3ef4e7002a17eef80e2a9514'),
   (Input: 31;  Expected: '0x4e074ec035707651726210950e241346aec8f6c6aaa504f416cd0ec92fa4c08340cca3827fb990d74b8f837c0bbafccb2d5739f2b59ff49cce5cfa4f285e083f'),
   (Input: 32;  Expected: '0xcb2c167bbad4d529cbdc48645756cf61b3838d6c0af14a9596dd105a172053e198c22c3669a792949274ff1ed687e80e4ae3b85ec70154a6f62d2cf13231b083'),
   (Input: 33;  Expected: '0x9a8a4ea7bbaf058c07a62a9f13de219abb2bd99738a7997bfaa373d61ce54c6a0ede112cb652d40682ff804552f9db4247de5858c45ccb9a8ac064881f05b92c'),
   (Input: 34;  Expected: '0xa7651109edfa702d76471ad0c4ffaaed200f5ed783a4ad834ced1b37bf4038af8472d767a7b0d08e146e079c4467468df30d89f14ae59fc75ecf927717abecdc'),
   (Input: 63;  Expected: '0xe24f626b1a12d956231a7bf17d7f976925cc186776da91543eb9b244454bc0b71956bce4e514bf1095fc61097eb39d67dc78ec6c78e640bcfb18fd110adaecfd'),
   (Input: 64;  Expected: '0x55de09270df2b8f2b8c35f082ae45acd55fca556fb4c7614a61531888e7d5502a2015b0c936fbddf4f6ccfcdba4d4e69139be2062c42a6b1acc03638b035d55e'),
   (Input: 65;  Expected: '0x51a424024d3eb88e2cf09e14e512a6ce27b1a95a087afe07c5138e191cbf8079fd740a262e47e6dffad44355548eebd2c1ebc24c8b7bbf266573b838a6b70ef8'),
   (Input: 100; Expected: '0x03cab91f85e1ffc286a297538200b80b39681f5fe06108557c354264127db6aaa271399af25c2cb240554921b3d878675f875dd244a7af22187015945b105558'),
   (Input: 117; Expected: '0xe9ca855bf340229a4446f46cb0b0e3cffaf1942b8a8b6e296d5b35621be9e6c40217a76d1461380d062e9f0ac8cee8e15b70b7762a6de367463ac84c4d56b49a'),
   (Input: 127; Expected: '0xab24840d31c5c19a8c5c0729e8bc327cb1b48088b135de8f04428985a0ef71d366388973625cb77d558f6dc4dcbe93c5d5327aedb83b0cbee34e656fde2962ee'),
   (Input: 128; Expected: '0xef4618e9126f6c54931e8f2ab5e12737ed4722932e107d05768ba59f484e0858b6b189ce0b1db3e18eea5355eb60dec5826be26cac759b7f2eab3a97ec111f10'),
   (Input: 129; Expected: '0xad7f01517787bfa75ceceab92d96f94f04600786a83cabe190e3b503af1d184d9db27577bdddb78fa052d8a086147add8ecc385b3f26c37180408311664bf9af'),
   (Input: 178; Expected: '0x99ae6a63885847e5b45ff4d2d2b0eb43e9fd722a0c7254eb4bcf706a484df9e300c61e6aa7c6620ddf2dabcc9b51257715f396f713606dbcd09f14c833becdb6'),
   (Input: 199; Expected: '0x33074a6aa23c6117037b426d16211bc41a29e38bf94bba4c2dce6659b0c4e5b63555a8b08a214905e1f795282a0a427cb90de7d3967d7ba975b58a7eb550eb3c'),
   (Input: 200; Expected: '0x6c5117105a9cf47347e5e59aeeacf833e503c3e537e75020c9363cdebafeab00dd478e96c3a0e11e4c2615284fddf47a079c2b49d650f0bbc167ba10f5bf25e8')
 );

 DATA_BLAKE2S : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0xc6d5f10d213cfa97b3317f115f6eae29419051524f14f29b39c4f620a6e4758d'),
   (Input: 31;  Expected: '0x2c82e8af7b3db4a4737546616f34026c0acdf0c2037ba138861af29e34b2eaff'),
   (Input: 32;  Expected: '0xc661e40d5ef223343c2513b19b0ba5a69c91e076be875c854830345de2741517'),
   (Input: 33;  Expected: '0xfae74bb4a48f325c4380ab694ed91ed6b0bb5d8eac825ae8ade73d4b7d7d1cb7'),
   (Input: 34;  Expected: '0xd6010f74459a82f459604a044fb2d21d93904427c44ebb22bd76694110fbf9df'),
   (Input: 63;  Expected: '0x0707f52c9629e5d926d19aaac0e31f96273627ddfbb85519f4d2abdda8107459'),
   (Input: 64;  Expected: '0xc55f4dc5612258bd600c4b078128919dca82a4f98022b9762826d596356dda14'),
   (Input: 65;  Expected: '0x7ce4f4e9e7357f74f15903f273a285e02d7fa976e94ae900d9a14b131f397aec'),
   (Input: 100; Expected: '0x4be6010f72c375b685dd57d66585b8c5f86eb1ac27b80ca20f041d44533a7005'),
   (Input: 117; Expected: '0xa37bc13f537b8800fc61170dd714cb938c0e62047a7c9d0061bd8a407fe29a13'),
   (Input: 127; Expected: '0xef42bf26aeae6d85c8c1a0d4304da676444a7c57944efc0496c300b391048b01'),
   (Input: 128; Expected: '0x54afb0c19b2fc2ed628d379f819a79ad940add19296099acabe26bdc67c9bd05'),
   (Input: 129; Expected: '0x31e1c3e9ce27f992329d933a02dafe206b856f90057803d1e537304e97f80885'),
   (Input: 178; Expected: '0xf95e620f0335c83afa8eda36b853a739158cd4f8910fa2aa30d0794352c65510'),
   (Input: 199; Expected: '0xbd881d0cac02bd2300d41dfd8936570ed940d8cef9632731f28ea472d43c4199'),
   (Input: 200; Expected: '0xc83b8ea4503d8a8d470c0ba7f977c2ea773e844d36d9a9e866a953c1338259ee')
 );

 DATA_TIGER2_5_192 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x31f8163acae71a73f662828258b8506f2d8d65062b550d71'),
   (Input: 31;  Expected: '0x4c3a22c2d96ab29ad12100b1f2cf6c52b0f75f4c75f049d3'),
   (Input: 32;  Expected: '0x5072d1575f95f75eb22169647a0f5b774bdc21dd8896528f'),
   (Input: 33;  Expected: '0x3fb8ab4e655028dbf2aab6ebeee5996a93fe0b4bb250fb6f'),
   (Input: 34;  Expected: '0x026780bd79297995ef4b5e0d9cbdb1fdb4f6df4aa94abee6'),
   (Input: 63;  Expected: '0xc45fc6510ee3ff3503c4c8795d3d27da2fd4f81e5edef179'),
   (Input: 64;  Expected: '0x7e056bc56de5385d47eb3e3a218b5cab1894449b8e0b55fa'),
   (Input: 65;  Expected: '0x6b6e1f82c0ea6b6a4b40678c8fd1d8ebdd49f3dc657ebc6a'),
   (Input: 100; Expected: '0xcf38de0d363bb17ee67f510900a48f156fc9e8429097509f'),
   (Input: 117; Expected: '0xc15eba0aa26d3668b97f9abfa4bfa0513057f35874f50ab0'),
   (Input: 127; Expected: '0x24b3fec9a6235309ae17ee5a972503b60a3e8017b66cdf12'),
   (Input: 128; Expected: '0x61485315bdca303a54a23b3fdf5ab410092824c0bd8b177a'),
   (Input: 129; Expected: '0x742c2dc251630e13016a4f968e640156e44bf3c6fc307665'),
   (Input: 178; Expected: '0xeac22e2e763c29b07346c531917a0fcb93fbc72daab36681'),
   (Input: 199; Expected: '0x2b173dfd8256085aa6b8336b5ce6fbb3d383c59547e5547c'),
   (Input: 200; Expected: '0xc2eee732fdbcdc4b0c8f57187a69b7017f9ad8771fc5ae36')
 );

 DATA_SNEFRU_8_256 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x93fdb3c044cf11b551b7527a59c9eb9cfb1716adc8fc0e1926b246038677968c'),
   (Input: 31;  Expected: '0xfb7c3d09e37f3388d9a90ca09c87cea58c6efbb8462562f7a4572a3eea194ed8'),
   (Input: 32;  Expected: '0xc5c78eba6dae1f3c9aefbe8e6608c60889dd8c648efc7b02befccd8bab46c54f'),
   (Input: 33;  Expected: '0x448c94af0ceddab0a6c2d06eda05f3ad6484512cccc61fa32f902a8e9021b851'),
   (Input: 34;  Expected: '0x99bd6565cf0c34bb93b74c81e68c5c096731e927c04eb374032e5507ce20175f'),
   (Input: 63;  Expected: '0x81a91002867a3e930493d9c833655165c63062ea66d65c45f2b1b29fec0d245f'),
   (Input: 64;  Expected: '0x565e627a7ac890df042565377b1413b30ff2fc1bafa861fa9070526375936299'),
   (Input: 65;  Expected: '0x0116ec1a605e1c56137427e06599be0bfc243a191988a4ced8a5b461b6f9bf67'),
   (Input: 100; Expected: '0x2d5fc09951112a362dc542262351087594e3643160cf87733ef6bc48d9cbe673'),
   (Input: 117; Expected: '0x3278279bc38c7483c3c072a892702a9ba0ea909b8a3412a4b48f333c99735433'),
   (Input: 127; Expected: '0xb22280ba8e1c973424ddf5be20497e1191634f7c72f46cb0757eb46dac168839'),
   (Input: 128; Expected: '0xf456475f82364ff1c5b4d14509b2a06d5fc8512378ec4d909fa9c57c336d2bdb'),
   (Input: 129; Expected: '0xc3b087f29c8237981b10227dbed68b203408df8aeb1805089a7a723f02b51992'),
   (Input: 178; Expected: '0x0e13d6fc033f4de4e9db360292e7a8c02514534e2cdff6fd69cbdcb515c8760b'),
   (Input: 199; Expected: '0x72e8f1ef4c8425356593a9ce4be37181911bcff9d9f426c93aa1622348a2c6e7'),
   (Input: 200; Expected: '0x8ba028b1ad51b06d8a92cf3541c817a22c483fb8aa9c4341345faddb8e166867')
 );

 DATA_GRINDAHL512 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x0b25b53c3812cb38fee71eae043331d5486154d4277d63f571ed7621ba1f38816163c16e6445568cde5dd4926249a2293b4c96f1e99d7f0697e9b0be24987fd9'),
   (Input: 31;  Expected: '0x9c8b6c9737348ea89adf7d3742344c416ca80e70d0c1a574b66d03c3a51fc363645a09b07e6804705726cbb0fda30ad755713f10b1dcd4bbc71d8d975401766b'),
   (Input: 32;  Expected: '0x04790923e624227751ada31cb344e77ba8cfabea22b9d09fd2f0a867d679e8cbb70665be0fe81554d1a2add1b69bcfd59c8fa452dd7847461c688da80a22df5f'),
   (Input: 33;  Expected: '0xd0af72a4c6ba8d8a690405f09c794030ae8c134df8ca60af5de4cc71458c0accba769abcb7d1c1b833921d52d44bec149d35110a98d03776ab9fc576f44044cf'),
   (Input: 34;  Expected: '0xfcfd8e4226478060980bc67a6191f55e772f44327897ea518ed092277112de8e8df8780c630f712a4ee2b4387d945e20e9d1628c5d513ea5ae61f9f2ea476cba'),
   (Input: 63;  Expected: '0x24b3f7df2ac9e96aa9ce2245e77a3b96a5c1c3c9d070f6806340f65ea9478d4b92ad48b0289d2540a4dc62fa511243eb7ca9808b59425ecc12343b8aff83d4a2'),
   (Input: 64;  Expected: '0x8830b562ce16b7afaf42dcb1af79624856cdea734b88f7b9f26b147f6e8c716aa0bb48b329ffee5ba8d0a37f205de2dcc0d9359e7e133aae14a201d22e82e60e'),
   (Input: 65;  Expected: '0xcca9753de1a1a717c1dfb06a1b9fd3bc7bb01ef228d2b10ddbb8e36fcfd30ee2ce6fb4b63c091506cef5c5458f89dd11991b829a817870fa25253697d369265e'),
   (Input: 100; Expected: '0xead32ea9bb5b7db55c19895cf6b9ea82bd17ee4a56ac508f3bbeb69a0e5f4df8cf492a02ea5db195f74e6101314ae4917758e0642e8981d947c1dfa16cf651b0'),
   (Input: 117; Expected: '0x4447132202fd4a94ae31af19bf454d2c46e4e8a1f82ab214f3eadd9d02eb9d7ebc72ddbf04bab2e0e3a553f4e6ec5b7c8724f20c887c8394b2f970524a3b845f'),
   (Input: 127; Expected: '0xf924af50f7cdc77b9199d1af7f1f7fcd454b8b670df3a1d22ec634a502f509f47ff0d6ede8eb26afb94ee45ef819acdd522680a5a6394aee34704f9f08e1a37c'),
   (Input: 128; Expected: '0xc86054fb58498874529532408a05101ad0d1753639716f96f56468c015880d7adfc2db4b94edcb50af6e66f87a0d595f7e29a5829edba17c2d039141aec90724'),
   (Input: 129; Expected: '0x3db136d934e5c22fbbe614fb7420d9cd70d74d1e868e078bbab97939039124543b0909de500b72114a110b1a94a6dcab623b3f0ac9eb102176023719a8243561'),
   (Input: 178; Expected: '0xbe7c6b085ccfa21344e46415a3bb139ee2ac1b87ae569e3f751a563280e879cc7910c357416101495cca5442d6260bf993e11ba1d5aedccad75afd130d4346fa'),
   (Input: 199; Expected: '0xeeefc607804883a8e4e24d349297380a7be6789f877d6edfd017b054d6dff6a7fcb1386c5695b76ff9997332125a2e7aadb9533761a2d9fd960f6be4646fbaf3'),
   (Input: 200; Expected: '0x13771dd2bd4e1d046acd57457b0cddd6c535d91923677315ad89f7bf2fd3573b31d5eff98eb88798a5383b90d36efabc5b4127eb6e592adceb6a0749bae01869')
 );

 DATA_HAVAL_5_256 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x1c3afb53f06ade5399c4797800b44abc301d9faaf698fe66ca36b18a26da5153'),
   (Input: 31;  Expected: '0x4cccbbaf8e991a805626c96f3d2850862ae7e77e970a6e7b818444a7c92c8cf9'),
   (Input: 32;  Expected: '0xc5b81863a6c8c1ac6cc3f429a7fce6ff6ecb1f459856d241f5c5f1820f229927'),
   (Input: 33;  Expected: '0x6453387b3f0b6d6dd6a8343cab021ceeedef2f8fd852ab35a8aa5472f3653909'),
   (Input: 34;  Expected: '0x71dd44d1eb0ced6208ac71360611b7ac50cbc49365c135fa253771814f8fd224'),
   (Input: 63;  Expected: '0x09182c9035cd025d5cca7f2a9525bccdf8314d6c03419987a03a0bec59e76e38'),
   (Input: 64;  Expected: '0xd6cc048cdd7c944ad99b1bb8ff9b48bf8f8ecfa783369e3d008902fedd98009f'),
   (Input: 65;  Expected: '0xe7e1ead7bad22f210bfe98825022a71e9ebc8b85cf8710b2ef6fb9e457fb96db'),
   (Input: 100; Expected: '0xef0ecb677bee8f32a0e234f9f1944528a17f2e148634d7ee99d490c21898b245'),
   (Input: 117; Expected: '0x883de42fabd84a49dbc4a5cc6a71f6b8c8c2b2ce91eadce672a21b0df5d38683'),
   (Input: 127; Expected: '0x0c57f4b86511b060b39c9d7b101fc6282642654890fc9dfdd010025e632c9ce8'),
   (Input: 128; Expected: '0x63829e28fce75643700ebe1e4750fc26001c81335401b19b5e86acf3866e4672'),
   (Input: 129; Expected: '0xa29f9c16a35abbcc06d5f3e77854008dea21c38093729ec347cd3cf24ab6fdc8'),
   (Input: 178; Expected: '0xf83274137a08ac4f8738587e643a85907716f2df0462d32673f5d79c5e301e6a'),
   (Input: 199; Expected: '0x9d08dcbcffe809a60e60fcad8b515ed73e339e73f885c5b50479d7ea2afb6e3b'),
   (Input: 200; Expected: '0x5e1e2503132805abbdd447a5428dc9ddf7071da09fc5bede1a2db78731177fee')
 );

 DATA_MD5 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x990d2e3e54e0d540e17e28bf089cbc8f'),
   (Input: 31;  Expected: '0x5120a7106123521029896a89890decbb'),
   (Input: 32;  Expected: '0x49848dfebea23abc37872a22bb76e1ea'),
   (Input: 33;  Expected: '0x62b3040c9f11e5ef68f5b029beffb3ec'),
   (Input: 34;  Expected: '0x61c9c3ec798fdb6fc587065114a093b5'),
   (Input: 63;  Expected: '0x89973c44bb3e207dc60d789e3b9b482b'),
   (Input: 64;  Expected: '0xe2ae3f3eeffb99c0b46f12254ad6eb4e'),
   (Input: 65;  Expected: '0x3c2b0369b053d0df325c7343f0a5401a'),
   (Input: 100; Expected: '0x98e0bd2b4eb38f4d7e6d33d1cb5fbc1d'),
   (Input: 117; Expected: '0x135a0450af2b16e8529060246e402a27'),
   (Input: 127; Expected: '0x74f3b69ddcd9d6ce64530eeef42cec35'),
   (Input: 128; Expected: '0xed31bf5fd4dbc2d509ac4cb880ec685d'),
   (Input: 129; Expected: '0x2cacdddc8999a30233627b929921202b'),
   (Input: 178; Expected: '0xc6f6aae119ba216edf22c62ed898bc56'),
   (Input: 199; Expected: '0xc5fc302e8942cb54a37a7c46adeab3d0'),
   (Input: 200; Expected: '0x9242480e2630061d3eccb16821e98d30')
 );

 DATA_RADIOGATUN32 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0x65024d09e2b8a46d8b6a2aa87af2445a9d640a74081e5d7a33062307a1c47b0d'),
   (Input: 31;  Expected: '0x32b17be7c6fedb037515313b5604e1661ca1f34e282107e20d3e907864751421'),
   (Input: 32;  Expected: '0xff4d011327d8dfccde7901523cd044fdc8c89479a831a61a8179ccb1eb6b34e7'),
   (Input: 33;  Expected: '0x92dd5fbface846262b32ebca67a20fa571a87c435c11daacaca4cd96da4c9c2a'),
   (Input: 34;  Expected: '0x289590b6bbe0da22917b8d62b5752c4ea032de707e753d98771da87e7a6f68d9'),
   (Input: 63;  Expected: '0xda5cf1e7f0b880c419201aeb2f537fe27594d9e239b738f1bc677d59f2927923'),
   (Input: 64;  Expected: '0x9b21fc33aa89b1a709c0af3b0305ee0ce491462ea34900d52f44682938f8b5ae'),
   (Input: 65;  Expected: '0xc2856589442488830608c6d9669f1d93bdb39c83616294499b36dffba17d2bc0'),
   (Input: 100; Expected: '0xbbda668f9d7b3cb2729b4a6a840b48ce3f938864d41a37a8b6c1df0926923291'),
   (Input: 117; Expected: '0x4e99747c8623d579b13f1cc6593a83c7a363d70157ae3a83165d817e836a22d0'),
   (Input: 127; Expected: '0x86517f426d2c55fd69d07a434f90bfee70539cde89f024dc1ba0e52d0ba5710a'),
   (Input: 128; Expected: '0xbb266e01e0ba48d3c8a5f465d41dde07c67396f05011b1eee0fc8c95e11b2525'),
   (Input: 129; Expected: '0x9935ccf10e79f6077845f4f6ad9a41df57a8ce7d854a0899090de8140ca38b67'),
   (Input: 178; Expected: '0x344442532a514e9dbb4b9c4232d45558e7e38510109ef62b17f54f402885cbde'),
   (Input: 199; Expected: '0xb76be67d94ce6014e5a125c371c22abfce3bbccc86f92dac31c394226b0c7912'),
   (Input: 200; Expected: '0x16696fe96e850fce272f90b59e9114e55098c03ee0d3e40e0d0616a1926a8ed8')
 );

 DATA_WHIRLPOOL : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0xeb986421c1650306056d522a52f2ab6aec30a7fbd930dff6927e9ca6db63501c999102e1fc594a476ac7ec3b6dffb1bd5f3e69ed0f175216d923798e32cb8096'),
   (Input: 31;  Expected: '0x8ec8f6838a7f78f9a1104a15e6e51f690b8bfe69e412438a6591dd90ff1bdee732ee32b75eda9d679900081a17e10d1dec77fdaa109a6ede060bbf3fa7959a8b'),
   (Input: 32;  Expected: '0x5687a34495d2ebe57ee157fb0eb4c9674079d6ce97d70a091abfb92fb0096f2065197ea7379bbbfcb10a148beec4381bf2dd3662bcaeb9077a014d5d51acff7b'),
   (Input: 33;  Expected: '0x017cf76d956e88528f0d1f48dbf895c645f0d9a7269ea21df15da6e24e15d711edbf88f0a6872c2074afb0f5c2905291395862b02e06019ffea960aa92ae7f98'),
   (Input: 34;  Expected: '0xc5ef49c4ba2aadecadd8820034378e53174d66b6bee6583ea3d36dde0ebe652be2571f9c5713e38e98f433817b3cfd4d633e3cbf62e6091943ed241c0b8cae37'),
   (Input: 63;  Expected: '0x9d3afbcb5b7bb86e27378090dc4664abc46f87bd69dbdf2481a5a1c25ebc216eeae5bd9a900f996d1fe8749c7127986602bd1221b73ea7c3cebcfd2fcf529773'),
   (Input: 64;  Expected: '0x0a2cf63dfda157514c4d9a54198265b7d09100922c8a6431d2b29b62c74f0ad7a0b0c661005aa686d5e2cbb5cab76563ee883bcbe52a4f4f32f2852ce3793b4c'),
   (Input: 65;  Expected: '0xfe6b3567fbbb1f1490d263248ef4f8ee7136a0c7627abb229c98fb90bd91710a15f135dffe1ab84a31984b3cc4869e870e64168efead9b8921a6139cd84b387f'),
   (Input: 100; Expected: '0xc95fb60f44a4eeb27cab9718ec3e3e6bdcd4bc3e2e59124f64defceeb17acf90121b65bf4693ae094e76f0db8d6f309a8531a474b53f49d5c4a7686fb9261d4f'),
   (Input: 117; Expected: '0xdff715603eaff8b2cfd3e0aa49ee50b0afdfa445e4f4b4a2b148959c4b23c6594bf8e2c81228db3c57c147e3b8a2fb91763b9a7abc0bff48052c30a9117d6b04'),
   (Input: 127; Expected: '0x76a8e2c8f91308134eb2a6485f4c8b1ed186632f5d4a477d5e2bd591c1a5913f39c97baf4a89ec56d0b46de38e72df6d43a0e8101f65e1441b415e4200cbe313'),
   (Input: 128; Expected: '0x661dc7ddbc9cd25ce94dfba19b7941daf12ff9a0a9d1b151d691ace392ed9d6c8d8cd1c12b2f0fda9ea116291cf81f04aca12f40fa2c482976228eb703d64029'),
   (Input: 129; Expected: '0xa9cf1d955a634da1f5b1068d1a0d631948ccd947c2e44eaf20584a79a810070bc3d30a208d63c023146d8bff79571ae6a9d10c90baf3e0031a733016f4473356'),
   (Input: 178; Expected: '0x53ca52a4baa75c13ef909fb6f6ec680338902bda1269c6a7db456c187a40f5e9e0dfce6f3d151e3b533f1b18c0b35a955095b24c94bd75a69bca5c67720c8e24'),
   (Input: 199; Expected: '0x26c9f7bed820bef29e35521bb6e89ccba04ad473eb7f8d9e51952ed4d414b71da10e57fc2d30ac8d6405722af51456bb515553a9fa9108cd022d270b9fda6ffe'),
   (Input: 200; Expected: '0xd88dceef0776780b8439dd8338cd972734d6e973b4dc43b6d298622d9ed0a1ab3e9a37664ecbd14d4155c65cde93dcfd70707ba4dd7eecbf15af2a5ffee48d1e')
 );

 DATA_MURMUR3_32 : array[1..16] of TTestItem<Integer, String> = (
   { NOTE: Input denotes the number of bytes to take from DATA_HASH_INPUT when executing test }
   (Input: 17;  Expected: '0xea99253f'),
   (Input: 31;  Expected: '0x1553afc2'),
   (Input: 32;  Expected: '0x9146e5ee'),
   (Input: 33;  Expected: '0x9d9efa16'),
   (Input: 34;  Expected: '0xdeffbebf'),
   (Input: 63;  Expected: '0x56311c1c'),
   (Input: 64;  Expected: '0x4dd59c1e'),
   (Input: 65;  Expected: '0xa96e7dea'),
   (Input: 100; Expected: '0x61afdbb2'),
   (Input: 117; Expected: '0x04d45504'),
   (Input: 127; Expected: '0x22f573a2'),
   (Input: 128; Expected: '0x545ab5d7'),
   (Input: 129; Expected: '0x45d66366'),
   (Input: 178; Expected: '0xeb1680c6'),
   (Input: 199; Expected: '0x33a16e6d'),
   (Input: 200; Expected: '0x442b55fe')
);

{ TRandomHashTest }

procedure TRandomHashTest.SetUp;
begin
  inherited;
end;

procedure TRandomHashTest.TearDown;
begin
  inherited;
end;

procedure TRandomHashTest.TestRandomHash_Standard;
var
  LCase : TTestItem<String, String>;
begin
  for LCase in DATA_RANDOMHASH_STANDARD do
   AssertEquals(ParseBytes(LCase.Expected), TRandomHash.Compute(ParseBytes(LCase.Input)));
  //TODO: remove when finalized -- WriteLn(Format('%s = %s', [LCase.Input, Bytes2Hex(TRandomHash.Compute(ParseBytes(LCase.Input)), True)]));
end;

procedure TRandomHashTest.TestRandomHash;
var
  LInput : TBytes;
  LCase : TTestItem<Integer, String>;
begin
  for LCase in DATA_RANDOMHASH do begin
    LInput := TArrayTool<byte>.Copy(ParseBytes(DATA_HASH_INPUT), 0, LCase.Input);
      AssertEquals(ParseBytes(LCase.Expected), TRandomHash.Compute(LInput));
    //TODO: remove when finalized -- WriteLn(Format('%s = %s', [Bytes2Hex(LInput, True), Bytes2Hex(TRandomHash.Compute(LInput), True)]));
  end;
end;

procedure TRandomHashTest.TestSHA2_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA2_256(), DATA_SHA2_256);
end;

procedure TRandomHashTest.TestSHA2_384;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA2_384(), DATA_SHA2_384);
end;

procedure TRandomHashTest.TestSHA3_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA3_256(), DATA_SHA3_256);
end;

procedure TRandomHashTest.TestSHA3_384;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA3_384(), DATA_SHA3_384);
end;

procedure TRandomHashTest.TestSHA3_512;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA3_512(), DATA_SHA3_512);
end;

procedure TRandomHashTest.TestRIPEMD160;
begin
  TestSubHash(THashFactory.TCrypto.CreateRIPEMD160(), DATA_RIPEMD160);
end;

procedure TRandomHashTest.TestRIPEMD256;
begin
  TestSubHash(THashFactory.TCrypto.CreateRIPEMD256(), DATA_RIPEMD256);
end;

procedure TRandomHashTest.TestRIPEMD320;
begin
  TestSubHash(THashFactory.TCrypto.CreateRIPEMD320(), DATA_RIPEMD320);
end;

procedure TRandomHashTest.TestBLAKE2B;
begin
  TestSubHash(THashFactory.TCrypto.CreateBlake2B(), DATA_BLAKE2B);
end;

procedure TRandomHashTest.TestBLAKE2S;
begin
  TestSubHash(THashFactory.TCrypto.CreateBlake2S(), DATA_BLAKE2S);
end;

procedure TRandomHashTest.TestTIGER2_5_192;
begin
  TestSubHash(THashFactory.TCrypto.CreateTiger2_5_192(), DATA_TIGER2_5_192);
end;

procedure TRandomHashTest.TestSNEFRU_8_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateSnefru_8_256(), DATA_SNEFRU_8_256);
end;

procedure TRandomHashTest.TestGRINDAHL512;
begin
  TestSubHash(THashFactory.TCrypto.CreateGrindahl512(), DATA_GRINDAHL512);
end;

procedure TRandomHashTest.TestHAVAL_5_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateHaval_5_256(), DATA_HAVAL_5_256);
end;

procedure TRandomHashTest.TestMD5;
begin
  TestSubHash(THashFactory.TCrypto.CreateMD5(), DATA_MD5);
end;

procedure TRandomHashTest.TestRADIOGATUN32;
begin
  TestSubHash(THashFactory.TCrypto.CreateRadioGatun32(), DATA_RADIOGATUN32);
end;

procedure TRandomHashTest.TestWHIRLPOOL;
begin
  TestSubHash(THashFactory.TCrypto.CreateWhirlPool(), DATA_WHIRLPOOL);
end;

procedure TRandomHashTest.TestMURMUR3_32;
begin
  TestSubHash(THashFactory.THash32.CreateMurmurHash3_x86_32(), DATA_MURMUR3_32);
end;

procedure TRandomHashTest.TestSubHash(AHasher : IHash; const ATestData : array of TTestItem<Integer, String>);
var
  LInput : TBytes;
  LCase : TTestItem<Integer, String>;
begin
  for LCase in ATestData do begin
    LInput := TArrayTool<byte>.Copy(ParseBytes(DATA_HASH_INPUT), 0, LCase.Input);
    AssertEquals(ParseBytes(LCase.Expected), AHasher.ComputeBytes(LInput).GetBytes);
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TRandomHashTest);
{$ELSE}
  RegisterTest(TTestRandomHash.Suite);
{$ENDIF FPC}

end.
