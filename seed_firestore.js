const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function seed() {
  console.log('Starting seed...');

  // ── HELPER ──────────────────────────────────────────────────────────────
  async function addCategory(name, parentId = null) {
    const ref = db.collection('categories').doc();
    await ref.set({ name, parent_id: parentId });
    return ref.id;
  }

  async function addItem(name, categoryId, subCategoryId, imageUrl) {
    await db.collection('items').add({
      name,
      category_id: categoryId,
      sub_category_id: subCategoryId || null,
      image_url: imageUrl || null,
    });
  }

  // ── ANIME ────────────────────────────────────────────────────────────────
  const animeId = await addCategory('Anime');

  const beliebtId = await addCategory('Beliebteste Animes', animeId);
  const dbId = await addCategory('Dragon Ball', animeId);
  const dsId = await addCategory('Demon Slayer', animeId);
  const aotId = await addCategory('Attack on Titan', animeId);
  const dnId = await addCategory('Death Note', animeId);
  const fmaId = await addCategory('Fullmetal Alchemist', animeId);
  const hxhId = await addCategory('Hunter x Hunter', animeId);
  const saoId = await addCategory('Sword Art Online', animeId);
  const mhaId = await addCategory('My Hero Academia', animeId);
  const ftId = await addCategory('Fairy Tail', animeId);
  const blId = await addCategory('Bleach', animeId);
  const tgId = await addCategory('Tokyo Ghoul', animeId);
  const jjkId = await addCategory('Jujutsu Kaisen', animeId);
  const vsId = await addCategory('Vinland Saga', animeId);
  const avId = await addCategory('Avatar: The Last Airbender', animeId);
  const cmId = await addCategory('Chainsaw Man', animeId);
  const sxfId = await addCategory('Spy x Family', animeId);
  const mpId = await addCategory('Mob Psycho 100', animeId);
  const veId = await addCategory('Violet Evergarden', animeId);

  // ONE PIECE unter Anime
  const opId = await addCategory('One Piece', animeId);
  const opAlleId = await addCategory('Alle Charaktere', opId);
  const opStrohId = await addCategory('Strohhutbande', opId);
  const opMarId = await addCategory('Marine', opId);
  const opRevId = await addCategory('Revolutionäre', opId);
  const opPirId = await addCategory('Piraten', opId);
  const opKaiId = await addCategory('Alle Kaiser', opId);
  const opPreId = await addCategory('Pre Timeskip', opId);
  const opPostId = await addCategory('Post Timeskip', opId);
  const opFraId = await addCategory('Frauen', opId);
  const opArcId = await addCategory('Arcs', opId);
  const opSchId = await addCategory('Schwertkämpfer', opId);
  const opTeuId = await addCategory('Teufelsfrucht-Nutzer', opId);
  const opOutId = await addCategory('Outfits der Strohhüte', opId);

  // NARUTO unter Anime
  const naId = await addCategory('Naruto', animeId);
  const naAlleId = await addCategory('Alle Charaktere', naId);
  const naKonId = await addCategory('Konoha Ninja', naId);
  const naAktId = await addCategory('Akatsuki', naId);
  const naKagId = await addCategory('Kage', naId);
  const naUchId = await addCategory('Uchiha Clan', naId);
  const naJinId = await addCategory('Jinchuuriki', naId);
  const naSanId = await addCategory('Legendäre Sannin', naId);
  const naFraId = await addCategory('Frauen', naId);
  const naArcId = await addCategory('Arcs', naId);

  // POKEMON unter Anime
  const pkId = await addCategory('Pokémon', animeId);
  const pkAlleId = await addCategory('Alle Pokémon', pkId);
  const pkGen1Id = await addCategory('Generation 1', pkId);
  const pkGen2Id = await addCategory('Generation 2', pkId);
  const pkGen3Id = await addCategory('Generation 3', pkId);
  const pkGen4Id = await addCategory('Generation 4', pkId);
  const pkLegId = await addCategory('Legendäre', pkId);
  const pkStartId = await addCategory('Alle Starter', pkId);
  const pkFeuId = await addCategory('Typ: Feuer', pkId);
  const pkWasId = await addCategory('Typ: Wasser', pkId);
  const pkElId = await addCategory('Typ: Elektro', pkId);
  const pkDrId = await addCategory('Typ: Drache', pkId);

  console.log('Categories created. Adding items...');

  // Beliebteste Animes
  const animeList = [
    ['One Piece','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Naruto','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Dragon Ball Z','https://cdn.myanimelist.net/images/anime/6/43049.jpg'],
    ['Attack on Titan','https://cdn.myanimelist.net/images/anime/10/47347.jpg'],
    ['Death Note','https://cdn.myanimelist.net/images/anime/9/9453.jpg'],
    ['Fullmetal Alchemist: Brotherhood','https://cdn.myanimelist.net/images/anime/1223/96541.jpg'],
    ['Demon Slayer','https://cdn.myanimelist.net/images/anime/1286/99889.jpg'],
    ['Hunter x Hunter','https://cdn.myanimelist.net/images/anime/11/33657.jpg'],
    ['Sword Art Online','https://cdn.myanimelist.net/images/anime/11/39717.jpg'],
    ['My Hero Academia','https://cdn.myanimelist.net/images/anime/10/78745.jpg'],
    ['Fairy Tail','https://cdn.myanimelist.net/images/anime/7/25022.jpg'],
    ['Bleach','https://cdn.myanimelist.net/images/anime/3/40451.jpg'],
    ['Tokyo Ghoul','https://cdn.myanimelist.net/images/anime/5/64449.jpg'],
    ['Jujutsu Kaisen','https://cdn.myanimelist.net/images/anime/1171/109222.jpg'],
    ['Vinland Saga','https://cdn.myanimelist.net/images/anime/1500/103005.jpg'],
    ['Re:Zero','https://cdn.myanimelist.net/images/anime/11/79410.jpg'],
    ['Black Clover','https://cdn.myanimelist.net/images/anime/2/88336.jpg'],
    ['Steins;Gate','https://cdn.myanimelist.net/images/anime/5/73199.jpg'],
    ['Overlord','https://cdn.myanimelist.net/images/anime/7/88924.jpg'],
    ['Cowboy Bebop','https://cdn.myanimelist.net/images/anime/4/19644.jpg'],
    ['Mob Psycho 100','https://cdn.myanimelist.net/images/anime/8/80356.jpg'],
    ['Violet Evergarden','https://cdn.myanimelist.net/images/anime/1795/95088.jpg'],
    ['Chainsaw Man','https://cdn.myanimelist.net/images/anime/1806/126216.jpg'],
    ['Spy x Family','https://cdn.myanimelist.net/images/anime/1441/122795.jpg'],
  ];
  for (const [name, url] of animeList) await addItem(name, animeId, beliebtId, url);

  // Dragon Ball
  const dbChars = [
    ['Goku','https://cdn.myanimelist.net/images/characters/10/71493.jpg'],
    ['Vegeta','https://cdn.myanimelist.net/images/characters/4/71497.jpg'],
    ['Gohan','https://cdn.myanimelist.net/images/characters/12/71494.jpg'],
    ['Piccolo','https://cdn.myanimelist.net/images/characters/13/71498.jpg'],
    ['Frieza','https://cdn.myanimelist.net/images/characters/8/71501.jpg'],
    ['Cell','https://cdn.myanimelist.net/images/characters/14/71503.jpg'],
    ['Majin Buu','https://cdn.myanimelist.net/images/characters/9/71504.jpg'],
    ['Trunks','https://cdn.myanimelist.net/images/characters/7/71499.jpg'],
    ['Krillin','https://cdn.myanimelist.net/images/characters/11/71495.jpg'],
    ['Android 18','https://cdn.myanimelist.net/images/characters/6/71502.jpg'],
    ['Broly','https://cdn.myanimelist.net/images/characters/5/297828.jpg'],
    ['Gogeta','https://cdn.myanimelist.net/images/characters/3/297829.jpg'],
    ['Vegito','https://cdn.myanimelist.net/images/characters/2/297830.jpg'],
    ['Beerus','https://cdn.myanimelist.net/images/characters/4/297831.jpg'],
    ['Jiren','https://cdn.myanimelist.net/images/characters/6/356801.jpg'],
    ['Hit','https://cdn.myanimelist.net/images/characters/8/356803.jpg'],
    ['Goten','https://cdn.myanimelist.net/images/characters/10/71500.jpg'],
    ['Bulma','https://cdn.myanimelist.net/images/characters/12/71496.jpg'],
    ['Whis','https://cdn.myanimelist.net/images/characters/7/297832.jpg'],
    ['Black Goku','https://cdn.myanimelist.net/images/characters/9/356805.jpg'],
  ];
  for (const [name, url] of dbChars) await addItem(name, animeId, dbId, url);

  // Demon Slayer
  const dsChars = [
    ['Tanjiro Kamado','https://cdn.myanimelist.net/images/characters/10/382395.jpg'],
    ['Nezuko Kamado','https://cdn.myanimelist.net/images/characters/4/382396.jpg'],
    ['Zenitsu Agatsuma','https://cdn.myanimelist.net/images/characters/7/382397.jpg'],
    ['Inosuke Hashibira','https://cdn.myanimelist.net/images/characters/3/382398.jpg'],
    ['Giyu Tomioka','https://cdn.myanimelist.net/images/characters/12/382399.jpg'],
    ['Shinobu Kocho','https://cdn.myanimelist.net/images/characters/9/382400.jpg'],
    ['Rengoku Kyojuro','https://cdn.myanimelist.net/images/characters/6/382401.jpg'],
    ['Tengen Uzui','https://cdn.myanimelist.net/images/characters/5/382402.jpg'],
    ['Muzan Kibutsuji','https://cdn.myanimelist.net/images/characters/8/382403.jpg'],
    ['Akaza','https://cdn.myanimelist.net/images/characters/11/382404.jpg'],
    ['Doma','https://cdn.myanimelist.net/images/characters/2/382405.jpg'],
    ['Kokushibo','https://cdn.myanimelist.net/images/characters/14/382406.jpg'],
    ['Kanao Tsuyuri','https://cdn.myanimelist.net/images/characters/4/416922.jpg'],
    ['Sanemi Shinazugawa','https://cdn.myanimelist.net/images/characters/6/416924.jpg'],
    ['Mitsuri Kanroji','https://cdn.myanimelist.net/images/characters/8/416926.jpg'],
    ['Obanai Iguro','https://cdn.myanimelist.net/images/characters/10/416928.jpg'],
    ['Yoriichi Tsugikuni','https://cdn.myanimelist.net/images/characters/12/416930.jpg'],
    ['Genya Shinazugawa','https://cdn.myanimelist.net/images/characters/3/416932.jpg'],
  ];
  for (const [name, url] of dsChars) await addItem(name, animeId, dsId, url);

  // Attack on Titan
  const aotChars = [
    ['Eren Yeager','https://cdn.myanimelist.net/images/characters/10/261745.jpg'],
    ['Mikasa Ackerman','https://cdn.myanimelist.net/images/characters/9/261746.jpg'],
    ['Armin Arlert','https://cdn.myanimelist.net/images/characters/8/261747.jpg'],
    ['Levi Ackerman','https://cdn.myanimelist.net/images/characters/6/261748.jpg'],
    ['Hange Zoë','https://cdn.myanimelist.net/images/characters/7/261749.jpg'],
    ['Erwin Smith','https://cdn.myanimelist.net/images/characters/5/261750.jpg'],
    ['Reiner Braun','https://cdn.myanimelist.net/images/characters/4/261751.jpg'],
    ['Bertholdt Hoover','https://cdn.myanimelist.net/images/characters/3/261752.jpg'],
    ['Annie Leonhart','https://cdn.myanimelist.net/images/characters/2/261753.jpg'],
    ['Zeke Yeager','https://cdn.myanimelist.net/images/characters/11/261754.jpg'],
    ['Historia Reiss','https://cdn.myanimelist.net/images/characters/12/261755.jpg'],
    ['Ymir','https://cdn.myanimelist.net/images/characters/13/261756.jpg'],
    ['Jean Kirstein','https://cdn.myanimelist.net/images/characters/14/261757.jpg'],
    ['Connie Springer','https://cdn.myanimelist.net/images/characters/15/261758.jpg'],
    ['Sasha Braus','https://cdn.myanimelist.net/images/characters/16/261759.jpg'],
    ['Pieck Finger','https://cdn.myanimelist.net/images/characters/3/369802.jpg'],
    ['Falco Grice','https://cdn.myanimelist.net/images/characters/7/369806.jpg'],
  ];
  for (const [name, url] of aotChars) await addItem(name, animeId, aotId, url);

  // Death Note
  const dnChars = [
    ['Light Yagami','https://cdn.myanimelist.net/images/characters/8/328843.jpg'],
    ['L Lawliet','https://cdn.myanimelist.net/images/characters/9/328844.jpg'],
    ['Misa Amane','https://cdn.myanimelist.net/images/characters/6/328845.jpg'],
    ['Ryuk','https://cdn.myanimelist.net/images/characters/5/328846.jpg'],
    ['Near','https://cdn.myanimelist.net/images/characters/4/328847.jpg'],
    ['Mello','https://cdn.myanimelist.net/images/characters/3/328848.jpg'],
    ['Rem','https://cdn.myanimelist.net/images/characters/2/328849.jpg'],
    ['Watari','https://cdn.myanimelist.net/images/characters/11/328850.jpg'],
    ['Teru Mikami','https://cdn.myanimelist.net/images/characters/7/328852.jpg'],
    ['Kiyomi Takada','https://cdn.myanimelist.net/images/characters/13/328853.jpg'],
  ];
  for (const [name, url] of dnChars) await addItem(name, animeId, dnId, url);

  // FMA
  const fmaChars = [
    ['Edward Elric','https://cdn.myanimelist.net/images/characters/7/53297.jpg'],
    ['Alphonse Elric','https://cdn.myanimelist.net/images/characters/8/53298.jpg'],
    ['Roy Mustang','https://cdn.myanimelist.net/images/characters/9/53299.jpg'],
    ['Winry Rockbell','https://cdn.myanimelist.net/images/characters/10/53300.jpg'],
    ['Riza Hawkeye','https://cdn.myanimelist.net/images/characters/11/53301.jpg'],
    ['Maes Hughes','https://cdn.myanimelist.net/images/characters/12/53302.jpg'],
    ['Scar','https://cdn.myanimelist.net/images/characters/13/53303.jpg'],
    ['Van Hohenheim','https://cdn.myanimelist.net/images/characters/14/53304.jpg'],
    ['Father','https://cdn.myanimelist.net/images/characters/15/53305.jpg'],
    ['Greed','https://cdn.myanimelist.net/images/characters/4/53306.jpg'],
    ['Envy','https://cdn.myanimelist.net/images/characters/3/53307.jpg'],
    ['Lust','https://cdn.myanimelist.net/images/characters/2/53308.jpg'],
    ['Gluttony','https://cdn.myanimelist.net/images/characters/5/53309.jpg'],
    ['Sloth','https://cdn.myanimelist.net/images/characters/6/53310.jpg'],
  ];
  for (const [name, url] of fmaChars) await addItem(name, animeId, fmaId, url);

  // HxH
  const hxhChars = [
    ['Gon Freecss','https://cdn.myanimelist.net/images/characters/7/427534.jpg'],
    ['Killua Zoldyck','https://cdn.myanimelist.net/images/characters/8/427535.jpg'],
    ['Kurapika','https://cdn.myanimelist.net/images/characters/9/427536.jpg'],
    ['Leorio','https://cdn.myanimelist.net/images/characters/10/427537.jpg'],
    ['Hisoka','https://cdn.myanimelist.net/images/characters/11/427538.jpg'],
    ['Chrollo Lucilfer','https://cdn.myanimelist.net/images/characters/12/427539.jpg'],
    ['Illumi Zoldyck','https://cdn.myanimelist.net/images/characters/13/427540.jpg'],
    ['Meruem','https://cdn.myanimelist.net/images/characters/14/427541.jpg'],
    ['Neferpitou','https://cdn.myanimelist.net/images/characters/15/427542.jpg'],
    ['Netero','https://cdn.myanimelist.net/images/characters/3/427544.jpg'],
    ['Biscuit Krueger','https://cdn.myanimelist.net/images/characters/4/427543.jpg'],
    ['Knuckle Bine','https://cdn.myanimelist.net/images/characters/2/427545.jpg'],
  ];
  for (const [name, url] of hxhChars) await addItem(name, animeId, hxhId, url);

  // SAO
  const saoChars = [
    ['Kirito','https://cdn.myanimelist.net/images/characters/7/204821.jpg'],
    ['Asuna','https://cdn.myanimelist.net/images/characters/8/204822.jpg'],
    ['Sinon','https://cdn.myanimelist.net/images/characters/9/247763.jpg'],
    ['Alice','https://cdn.myanimelist.net/images/characters/10/357481.jpg'],
    ['Yui','https://cdn.myanimelist.net/images/characters/11/204823.jpg'],
    ['Klein','https://cdn.myanimelist.net/images/characters/12/204824.jpg'],
    ['Leafa','https://cdn.myanimelist.net/images/characters/14/204826.jpg'],
    ['Eugeo','https://cdn.myanimelist.net/images/characters/4/357482.jpg'],
    ['Agil','https://cdn.myanimelist.net/images/characters/13/204825.jpg'],
    ['Bercouli','https://cdn.myanimelist.net/images/characters/3/357483.jpg'],
  ];
  for (const [name, url] of saoChars) await addItem(name, animeId, saoId, url);

  // MHA
  const mhaChars = [
    ['Izuku Midoriya','https://cdn.myanimelist.net/images/characters/2/319011.jpg'],
    ['Katsuki Bakugo','https://cdn.myanimelist.net/images/characters/3/319012.jpg'],
    ['All Might','https://cdn.myanimelist.net/images/characters/4/319013.jpg'],
    ['Shoto Todoroki','https://cdn.myanimelist.net/images/characters/5/319014.jpg'],
    ['Ochaco Uraraka','https://cdn.myanimelist.net/images/characters/6/319015.jpg'],
    ['Tenya Iida','https://cdn.myanimelist.net/images/characters/7/319016.jpg'],
    ['Eraserhead','https://cdn.myanimelist.net/images/characters/8/319017.jpg'],
    ['Endeavor','https://cdn.myanimelist.net/images/characters/9/319018.jpg'],
    ['Hawks','https://cdn.myanimelist.net/images/characters/10/397833.jpg'],
    ['Tomura Shigaraki','https://cdn.myanimelist.net/images/characters/11/319019.jpg'],
    ['Dabi','https://cdn.myanimelist.net/images/characters/12/319020.jpg'],
    ['Toga Himiko','https://cdn.myanimelist.net/images/characters/13/319021.jpg'],
    ['Best Jeanist','https://cdn.myanimelist.net/images/characters/3/397835.jpg'],
    ['Mirio Togata','https://cdn.myanimelist.net/images/characters/5/397837.jpg'],
  ];
  for (const [name, url] of mhaChars) await addItem(name, animeId, mhaId, url);

  // Fairy Tail
  const ftChars = [
    ['Natsu Dragneel','https://cdn.myanimelist.net/images/characters/2/56563.jpg'],
    ['Lucy Heartfilia','https://cdn.myanimelist.net/images/characters/3/56564.jpg'],
    ['Erza Scarlet','https://cdn.myanimelist.net/images/characters/4/56565.jpg'],
    ['Gray Fullbuster','https://cdn.myanimelist.net/images/characters/5/56566.jpg'],
    ['Happy','https://cdn.myanimelist.net/images/characters/6/56567.jpg'],
    ['Wendy Marvell','https://cdn.myanimelist.net/images/characters/7/56568.jpg'],
    ['Makarov Dreyar','https://cdn.myanimelist.net/images/characters/8/56569.jpg'],
    ['Laxus Dreyar','https://cdn.myanimelist.net/images/characters/9/56570.jpg'],
    ['Jellal Fernandes','https://cdn.myanimelist.net/images/characters/10/56571.jpg'],
    ['Zeref','https://cdn.myanimelist.net/images/characters/11/56572.jpg'],
    ['Acnologia','https://cdn.myanimelist.net/images/characters/12/56573.jpg'],
    ['Gildarts Clive','https://cdn.myanimelist.net/images/characters/13/56574.jpg'],
    ['Mirajane Strauss','https://cdn.myanimelist.net/images/characters/3/56575.jpg'],
  ];
  for (const [name, url] of ftChars) await addItem(name, animeId, ftId, url);

  // Bleach
  const blChars = [
    ['Ichigo Kurosaki','https://cdn.myanimelist.net/images/characters/4/422423.jpg'],
    ['Rukia Kuchiki','https://cdn.myanimelist.net/images/characters/5/422424.jpg'],
    ['Orihime Inoue','https://cdn.myanimelist.net/images/characters/6/422425.jpg'],
    ['Uryu Ishida','https://cdn.myanimelist.net/images/characters/7/422426.jpg'],
    ['Byakuya Kuchiki','https://cdn.myanimelist.net/images/characters/9/422428.jpg'],
    ['Renji Abarai','https://cdn.myanimelist.net/images/characters/10/422429.jpg'],
    ['Toshiro Hitsugaya','https://cdn.myanimelist.net/images/characters/11/422430.jpg'],
    ['Sosuke Aizen','https://cdn.myanimelist.net/images/characters/12/422431.jpg'],
    ['Kisuke Urahara','https://cdn.myanimelist.net/images/characters/13/422432.jpg'],
    ['Grimmjow Jaegerjaquez','https://cdn.myanimelist.net/images/characters/3/422434.jpg'],
    ['Ulquiorra Cifer','https://cdn.myanimelist.net/images/characters/2/422435.jpg'],
    ['Yhwach','https://cdn.myanimelist.net/images/characters/4/458076.jpg'],
    ['Kenpachi Zaraki','https://cdn.myanimelist.net/images/characters/6/458078.jpg'],
    ['Rangiku Matsumoto','https://cdn.myanimelist.net/images/characters/8/458080.jpg'],
  ];
  for (const [name, url] of blChars) await addItem(name, animeId, blId, url);

  // Tokyo Ghoul
  const tgChars = [
    ['Ken Kaneki','https://cdn.myanimelist.net/images/characters/9/253969.jpg'],
    ['Touka Kirishima','https://cdn.myanimelist.net/images/characters/10/253970.jpg'],
    ['Rize Kamishiro','https://cdn.myanimelist.net/images/characters/11/253971.jpg'],
    ['Hide Nagachika','https://cdn.myanimelist.net/images/characters/12/253972.jpg'],
    ['Juuzou Suzuya','https://cdn.myanimelist.net/images/characters/13/253973.jpg'],
    ['Kishou Arima','https://cdn.myanimelist.net/images/characters/14/253974.jpg'],
    ['Uta','https://cdn.myanimelist.net/images/characters/2/253976.jpg'],
    ['Shuu Tsukiyama','https://cdn.myanimelist.net/images/characters/6/253978.jpg'],
    ['Yoshimura','https://cdn.myanimelist.net/images/characters/5/253977.jpg'],
    ['Naki','https://cdn.myanimelist.net/images/characters/3/253975.jpg'],
  ];
  for (const [name, url] of tgChars) await addItem(name, animeId, tgId, url);

  // JJK
  const jjkChars = [
    ['Yuji Itadori','https://cdn.myanimelist.net/images/characters/2/512591.jpg'],
    ['Megumi Fushiguro','https://cdn.myanimelist.net/images/characters/3/512592.jpg'],
    ['Nobara Kugisaki','https://cdn.myanimelist.net/images/characters/4/512593.jpg'],
    ['Satoru Gojo','https://cdn.myanimelist.net/images/characters/5/512594.jpg'],
    ['Suguru Geto','https://cdn.myanimelist.net/images/characters/6/512595.jpg'],
    ['Ryomen Sukuna','https://cdn.myanimelist.net/images/characters/7/512596.jpg'],
    ['Aoi Todo','https://cdn.myanimelist.net/images/characters/8/512597.jpg'],
    ['Nanami Kento','https://cdn.myanimelist.net/images/characters/9/512598.jpg'],
    ['Toge Inumaki','https://cdn.myanimelist.net/images/characters/10/512599.jpg'],
    ['Maki Zenin','https://cdn.myanimelist.net/images/characters/12/512601.jpg'],
    ['Toji Fushiguro','https://cdn.myanimelist.net/images/characters/13/512602.jpg'],
    ['Yuta Okkotsu','https://cdn.myanimelist.net/images/characters/14/512603.jpg'],
    ['Panda','https://cdn.myanimelist.net/images/characters/11/512600.jpg'],
  ];
  for (const [name, url] of jjkChars) await addItem(name, animeId, jjkId, url);

  // Vinland Saga
  const vsChars = [
    ['Thorfinn','https://cdn.myanimelist.net/images/characters/8/394774.jpg'],
    ['Askeladd','https://cdn.myanimelist.net/images/characters/9/394775.jpg'],
    ['Thorkell','https://cdn.myanimelist.net/images/characters/10/394776.jpg'],
    ['Canute','https://cdn.myanimelist.net/images/characters/11/394777.jpg'],
    ['Einar','https://cdn.myanimelist.net/images/characters/14/394780.jpg'],
    ['Thors','https://cdn.myanimelist.net/images/characters/5/394783.jpg'],
    ['Snake','https://cdn.myanimelist.net/images/characters/2/394782.jpg'],
    ['Gudrid','https://cdn.myanimelist.net/images/characters/3/394781.jpg'],
    ['Leif Erikson','https://cdn.myanimelist.net/images/characters/12/394778.jpg'],
    ['Floki','https://cdn.myanimelist.net/images/characters/13/394779.jpg'],
  ];
  for (const [name, url] of vsChars) await addItem(name, animeId, vsId, url);

  // Avatar
  const avChars = [
    ['Aang','https://cdn.myanimelist.net/images/characters/7/284813.jpg'],
    ['Katara','https://cdn.myanimelist.net/images/characters/9/284814.jpg'],
    ['Sokka','https://cdn.myanimelist.net/images/characters/11/284815.jpg'],
    ['Toph Beifong','https://cdn.myanimelist.net/images/characters/13/284816.jpg'],
    ['Zuko','https://cdn.myanimelist.net/images/characters/5/284817.jpg'],
    ['Azula','https://cdn.myanimelist.net/images/characters/6/284821.jpg'],
    ['Iroh','https://cdn.myanimelist.net/images/characters/10/284823.jpg'],
    ['Ozai','https://cdn.myanimelist.net/images/characters/8/284822.jpg'],
    ['Ty Lee','https://cdn.myanimelist.net/images/characters/12/284824.jpg'],
    ['Mai','https://cdn.myanimelist.net/images/characters/14/284825.jpg'],
    ['Suki','https://cdn.myanimelist.net/images/characters/4/284820.jpg'],
    ['König Bumi','https://cdn.myanimelist.net/images/characters/5/284830.jpg'],
    ['Yue','https://cdn.myanimelist.net/images/characters/2/284828.jpg'],
    ['Jet','https://cdn.myanimelist.net/images/characters/3/284831.jpg'],
  ];
  for (const [name, url] of avChars) await addItem(name, animeId, avId, url);

  // Chainsaw Man
  const cmChars = [
    ['Denji','https://cdn.myanimelist.net/images/characters/2/542798.jpg'],
    ['Power','https://cdn.myanimelist.net/images/characters/3/542799.jpg'],
    ['Aki Hayakawa','https://cdn.myanimelist.net/images/characters/4/542800.jpg'],
    ['Makima','https://cdn.myanimelist.net/images/characters/5/542801.jpg'],
    ['Reze','https://cdn.myanimelist.net/images/characters/6/542802.jpg'],
    ['Kobeni Higashiyama','https://cdn.myanimelist.net/images/characters/7/542803.jpg'],
    ['Himeno','https://cdn.myanimelist.net/images/characters/8/542804.jpg'],
    ['Quanxi','https://cdn.myanimelist.net/images/characters/9/542805.jpg'],
    ['Kishibe','https://cdn.myanimelist.net/images/characters/11/542807.jpg'],
    ['Katana Man','https://cdn.myanimelist.net/images/characters/10/542806.jpg'],
  ];
  for (const [name, url] of cmChars) await addItem(name, animeId, cmId, url);

  // Spy x Family
  const sxfChars = [
    ['Loid Forger','https://cdn.myanimelist.net/images/characters/2/534605.jpg'],
    ['Yor Forger','https://cdn.myanimelist.net/images/characters/3/534606.jpg'],
    ['Anya Forger','https://cdn.myanimelist.net/images/characters/4/534607.jpg'],
    ['Franky Franklin','https://cdn.myanimelist.net/images/characters/5/534608.jpg'],
    ['Yuri Briar','https://cdn.myanimelist.net/images/characters/6/534609.jpg'],
    ['Damian Desmond','https://cdn.myanimelist.net/images/characters/7/534610.jpg'],
    ['Becky Blackbell','https://cdn.myanimelist.net/images/characters/8/534611.jpg'],
    ['Bond Forger','https://cdn.myanimelist.net/images/characters/9/534612.jpg'],
  ];
  for (const [name, url] of sxfChars) await addItem(name, animeId, sxfId, url);

  // Mob Psycho
  const mpChars = [
    ['Mob (Shigeo Kageyama)','https://cdn.myanimelist.net/images/characters/2/315440.jpg'],
    ['Reigen Arataka','https://cdn.myanimelist.net/images/characters/3/315441.jpg'],
    ['Dimple','https://cdn.myanimelist.net/images/characters/4/315442.jpg'],
    ['Ritsu Kageyama','https://cdn.myanimelist.net/images/characters/5/315443.jpg'],
    ['Teruki Hanazawa','https://cdn.myanimelist.net/images/characters/6/315444.jpg'],
    ['Sho Suzuki','https://cdn.myanimelist.net/images/characters/7/315445.jpg'],
    ['Toichiro Suzuki','https://cdn.myanimelist.net/images/characters/8/315446.jpg'],
  ];
  for (const [name, url] of mpChars) await addItem(name, animeId, mpId, url);

  // Violet Evergarden
  const veChars = [
    ['Violet Evergarden','https://cdn.myanimelist.net/images/characters/2/331067.jpg'],
    ['Gilbert Bougainvillea','https://cdn.myanimelist.net/images/characters/3/331068.jpg'],
    ['Claudia Hodgins','https://cdn.myanimelist.net/images/characters/4/331069.jpg'],
    ['Cattleya Baudelaire','https://cdn.myanimelist.net/images/characters/5/331070.jpg'],
    ['Benedict Blue','https://cdn.myanimelist.net/images/characters/6/331071.jpg'],
    ['Iris Cannary','https://cdn.myanimelist.net/images/characters/7/331072.jpg'],
    ['Dietfried Bougainvillea','https://cdn.myanimelist.net/images/characters/9/331074.jpg'],
  ];
  for (const [name, url] of veChars) await addItem(name, animeId, veId, url);

  // ONE PIECE Items
  const opStrohChars = [
    ['Ruffy','https://cdn.myanimelist.net/images/characters/9/310307.jpg'],
    ['Zoro','https://cdn.myanimelist.net/images/characters/3/100534.jpg'],
    ['Nami','https://cdn.myanimelist.net/images/characters/9/112263.jpg'],
    ['Lysop','https://cdn.myanimelist.net/images/characters/9/131317.jpg'],
    ['Sanji','https://cdn.myanimelist.net/images/characters/11/174521.jpg'],
    ['Chopper','https://cdn.myanimelist.net/images/characters/3/272334.jpg'],
    ['Robin','https://cdn.myanimelist.net/images/characters/2/225811.jpg'],
    ['Franky','https://cdn.myanimelist.net/images/characters/9/131742.jpg'],
    ['Brook','https://cdn.myanimelist.net/images/characters/4/130573.jpg'],
    ['Jinbe','https://cdn.myanimelist.net/images/characters/3/49734.jpg'],
  ];
  for (const [name, url] of opStrohChars) await addItem(name, opId, opStrohId, url);

  const opMarChars = [
    ['Akainu','https://cdn.myanimelist.net/images/characters/5/280141.jpg'],
    ['Aokiji','https://cdn.myanimelist.net/images/characters/9/280143.jpg'],
    ['Kizaru','https://cdn.myanimelist.net/images/characters/11/280145.jpg'],
    ['Sengoku','https://cdn.myanimelist.net/images/characters/14/68327.jpg'],
    ['Garp','https://cdn.myanimelist.net/images/characters/2/68326.jpg'],
    ['Smoker','https://cdn.myanimelist.net/images/characters/8/68310.jpg'],
    ['Tashigi','https://cdn.myanimelist.net/images/characters/15/68312.jpg'],
    ['Fujitora','https://cdn.myanimelist.net/images/characters/13/249788.jpg'],
    ['Ryokugyu','https://cdn.myanimelist.net/images/characters/10/404514.jpg'],
    ['Koby','https://cdn.myanimelist.net/images/characters/8/68317.jpg'],
  ];
  for (const [name, url] of opMarChars) await addItem(name, opId, opMarId, url);

  const opPirChars = [
    ['Whitebeard','https://cdn.myanimelist.net/images/characters/2/68321.jpg'],
    ['Shanks','https://cdn.myanimelist.net/images/characters/3/68319.jpg'],
    ['Big Mom','https://cdn.myanimelist.net/images/characters/8/307918.jpg'],
    ['Kaido','https://cdn.myanimelist.net/images/characters/6/307914.jpg'],
    ['Blackbeard','https://cdn.myanimelist.net/images/characters/7/68325.jpg'],
    ['Ace','https://cdn.myanimelist.net/images/characters/3/68322.jpg'],
    ['Law','https://cdn.myanimelist.net/images/characters/6/249700.jpg'],
    ['Kid','https://cdn.myanimelist.net/images/characters/10/249702.jpg'],
    ['Mihawk','https://cdn.myanimelist.net/images/characters/12/68320.jpg'],
    ['Hancock','https://cdn.myanimelist.net/images/characters/2/68331.jpg'],
    ['Perona','https://cdn.myanimelist.net/images/characters/6/68333.jpg'],
    ['Reiju','https://cdn.myanimelist.net/images/characters/5/356753.jpg'],
    ['Yamato','https://cdn.myanimelist.net/images/characters/3/404511.jpg'],
    ['Ulti','https://cdn.myanimelist.net/images/characters/9/404507.jpg'],
    ['Kinemon','https://cdn.myanimelist.net/images/characters/14/249710.jpg'],
  ];
  for (const [name, url] of opPirChars) await addItem(name, opId, opPirId, url);

  const opRevChars = [
    ['Dragon','https://cdn.myanimelist.net/images/characters/5/68330.jpg'],
    ['Sabo','https://cdn.myanimelist.net/images/characters/12/249703.jpg'],
    ['Ivankov','https://cdn.myanimelist.net/images/characters/11/68339.jpg'],
    ['Koala','https://cdn.myanimelist.net/images/characters/3/249706.jpg'],
  ];
  for (const [name, url] of opRevChars) await addItem(name, opId, opRevId, url);

  // NARUTO Items
  const naKonChars = [
    ['Naruto','https://cdn.myanimelist.net/images/characters/2/284121.jpg'],
    ['Sasuke','https://cdn.myanimelist.net/images/characters/5/232380.jpg'],
    ['Sakura','https://cdn.myanimelist.net/images/characters/12/232378.jpg'],
    ['Kakashi','https://cdn.myanimelist.net/images/characters/7/284122.jpg'],
    ['Rock Lee','https://cdn.myanimelist.net/images/characters/7/43907.jpg'],
    ['Neji','https://cdn.myanimelist.net/images/characters/4/43908.jpg'],
    ['Hinata','https://cdn.myanimelist.net/images/characters/6/232376.jpg'],
    ['Shikamaru','https://cdn.myanimelist.net/images/characters/3/43906.jpg'],
    ['Ino','https://cdn.myanimelist.net/images/characters/7/43909.jpg'],
    ['Choji','https://cdn.myanimelist.net/images/characters/11/43910.jpg'],
    ['Gaara','https://cdn.myanimelist.net/images/characters/3/232382.jpg'],
    ['Minato','https://cdn.myanimelist.net/images/characters/9/232374.jpg'],
    ['Tsunade','https://cdn.myanimelist.net/images/characters/13/43902.jpg'],
    ['Jiraiya','https://cdn.myanimelist.net/images/characters/2/43904.jpg'],
    ['Orochimaru','https://cdn.myanimelist.net/images/characters/3/43905.jpg'],
    ['Guy','https://cdn.myanimelist.net/images/characters/5/43922.jpg'],
    ['Asuma','https://cdn.myanimelist.net/images/characters/6/43921.jpg'],
    ['Kurenai','https://cdn.myanimelist.net/images/characters/7/43917.jpg'],
  ];
  for (const [name, url] of naKonChars) await addItem(name, naId, naKonId, url);

  const naAktChars = [
    ['Pain / Nagato','https://cdn.myanimelist.net/images/characters/14/232386.jpg'],
    ['Itachi','https://cdn.myanimelist.net/images/characters/5/232384.jpg'],
    ['Kisame','https://cdn.myanimelist.net/images/characters/9/43912.jpg'],
    ['Konan','https://cdn.myanimelist.net/images/characters/2/232388.jpg'],
    ['Deidara','https://cdn.myanimelist.net/images/characters/7/232390.jpg'],
    ['Sasori','https://cdn.myanimelist.net/images/characters/4/232392.jpg'],
    ['Hidan','https://cdn.myanimelist.net/images/characters/11/43913.jpg'],
    ['Kakuzu','https://cdn.myanimelist.net/images/characters/14/43914.jpg'],
    ['Tobi / Obito','https://cdn.myanimelist.net/images/characters/6/232394.jpg'],
    ['Zetsu','https://cdn.myanimelist.net/images/characters/3/43911.jpg'],
  ];
  for (const [name, url] of naAktChars) await addItem(name, naId, naAktId, url);

  const naUchChars = [
    ['Itachi','https://cdn.myanimelist.net/images/characters/5/232384.jpg'],
    ['Sasuke','https://cdn.myanimelist.net/images/characters/5/232380.jpg'],
    ['Obito','https://cdn.myanimelist.net/images/characters/6/232394.jpg'],
    ['Madara','https://cdn.myanimelist.net/images/characters/10/232396.jpg'],
    ['Shisui','https://cdn.myanimelist.net/images/characters/4/232402.jpg'],
    ['Indra','https://cdn.myanimelist.net/images/characters/5/232404.jpg'],
  ];
  for (const [name, url] of naUchChars) await addItem(name, naId, naUchId, url);

  const naKagChars = [
    ['Hashirama','https://cdn.myanimelist.net/images/characters/5/232370.jpg'],
    ['Tobirama','https://cdn.myanimelist.net/images/characters/8/232372.jpg'],
    ['Hiruzen','https://cdn.myanimelist.net/images/characters/3/43903.jpg'],
    ['Minato','https://cdn.myanimelist.net/images/characters/9/232374.jpg'],
    ['Tsunade','https://cdn.myanimelist.net/images/characters/13/43902.jpg'],
    ['Kakashi (Hokage)','https://cdn.myanimelist.net/images/characters/7/284122.jpg'],
    ['Naruto (Hokage)','https://cdn.myanimelist.net/images/characters/2/284121.jpg'],
    ['Gaara (Kazekage)','https://cdn.myanimelist.net/images/characters/3/232382.jpg'],
    ['A (Raikage)','https://cdn.myanimelist.net/images/characters/11/43919.jpg'],
    ['Mei Terumi','https://cdn.myanimelist.net/images/characters/6/232400.jpg'],
  ];
  for (const [name, url] of naKagChars) await addItem(name, naId, naKagId, url);

  // POKEMON Items
  const gen1Pokemon = [
    ['Bisasam','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png'],
    ['Glumanda','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png'],
    ['Glurak','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png'],
    ['Schiggy','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/7.png'],
    ['Turtok','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png'],
    ['Pikachu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png'],
    ['Evoli','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/133.png'],
    ['Gengar','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/94.png'],
    ['Relaxo','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/143.png'],
    ['Dragoran','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/149.png'],
    ['Mewtu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png'],
    ['Mew','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/151.png'],
    ['Garados','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/130.png'],
    ['Arkani','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/59.png'],
    ['Nidoking','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/34.png'],
    ['Machomei','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/68.png'],
    ['Tauboss','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/38.png'],
    ['Knogga','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/105.png'],
  ];
  for (const [name, url] of gen1Pokemon) await addItem(name, pkId, pkGen1Id, url);

  const gen2Pokemon = [
    ['Endivie','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/152.png'],
    ['Feurigel','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/155.png'],
    ['Karnimani','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/158.png'],
    ['Pichu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/172.png'],
    ['Togepi','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/175.png'],
    ['Lugia','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/249.png'],
    ['Ho-Oh','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/250.png'],
    ['Celebi','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/251.png'],
    ['Ampharos','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/181.png'],
    ['Tyranitar','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/248.png'],
    ['Skaraborn','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/212.png'],
    ['Hasslo','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/197.png'],
  ];
  for (const [name, url] of gen2Pokemon) await addItem(name, pkId, pkGen2Id, url);

  const gen3Pokemon = [
    ['Geckarbor','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/252.png'],
    ['Flemmli','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/255.png'],
    ['Hydropi','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/258.png'],
    ['Rayquaza','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/384.png'],
    ['Groudon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/383.png'],
    ['Kyogre','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/382.png'],
    ['Latios','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/381.png'],
    ['Latias','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/380.png'],
    ['Metagross','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/376.png'],
    ['Relaxo (Hoenn)','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/334.png'],
  ];
  for (const [name, url] of gen3Pokemon) await addItem(name, pkId, pkGen3Id, url);

  const gen4Pokemon = [
    ['Chelast','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/387.png'],
    ['Panflam','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/390.png'],
    ['Plinfa','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/393.png'],
    ['Lucario','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/448.png'],
    ['Dialga','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/483.png'],
    ['Palkia','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/484.png'],
    ['Giratina','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/487.png'],
    ['Arceus','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/493.png'],
    ['Darkrai','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/491.png'],
    ['Garchomp','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/445.png'],
    ['Rizeros','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/464.png'],
  ];
  for (const [name, url] of gen4Pokemon) await addItem(name, pkId, pkGen4Id, url);

  const legendPokemon = [
    ['Mewtu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png'],
    ['Mew','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/151.png'],
    ['Lugia','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/249.png'],
    ['Ho-Oh','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/250.png'],
    ['Rayquaza','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/384.png'],
    ['Groudon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/383.png'],
    ['Kyogre','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/382.png'],
    ['Dialga','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/483.png'],
    ['Palkia','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/484.png'],
    ['Giratina','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/487.png'],
    ['Arceus','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/493.png'],
    ['Darkrai','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/491.png'],
    ['Zacian','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/888.png'],
    ['Zamazenta','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/889.png'],
    ['Koraidon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1007.png'],
    ['Miraidon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1008.png'],
  ];
  for (const [name, url] of legendPokemon) await addItem(name, pkId, pkLegId, url);

  // ── ESSEN ────────────────────────────────────────────────────────────────
  const essenId = await addCategory('Essen');
  const tkId = await addCategory('Türkische Küche', essenId);
  const ikId = await addCategory('Italienische Küche', essenId);
  const jkId = await addCategory('Japanische Küche', essenId);
  const mxId = await addCategory('Mexikanische Küche', essenId);
  const akId = await addCategory('Amerikanische Küche', essenId);
  const indId = await addCategory('Indische Küche', essenId);
  const cnId = await addCategory('Chinesische Küche', essenId);
  const ffId = await addCategory('Fast Food', essenId);
  const desId = await addCategory('Desserts & Süßes', essenId);
  const getId = await addCategory('Getränke', essenId);
  const snId = await addCategory('Snacks', essenId);

  // Türkische Küche
  const tkItems = [
    ['Döner Kebab','https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/D%C3%B6ner_Kebab.jpg/240px-D%C3%B6ner_Kebab.jpg'],
    ['Adana Kebab','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Adana_Kebab.jpg/320px-Adana_Kebab.jpg'],
    ['Iskender Kebab','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Iskender_kebab.jpg/320px-Iskender_kebab.jpg'],
    ['Şiş Kebab','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Sis_kebab.jpg/320px-Sis_kebab.jpg'],
    ['Köfte','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Turkish_kofte.jpg/320px-Turkish_kofte.jpg'],
    ['Lahmacun','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Lahmacun.jpg/320px-Lahmacun.jpg'],
    ['Pide','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Turkish_pide.jpg/320px-Turkish_pide.jpg'],
    ['Mantı','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Manti.jpg/320px-Manti.jpg'],
    ['Baklava','https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Baklava_-_Turkish_special%2C_80-ply.JPEG/320px-Baklava_-_Turkish_special%2C_80-ply.JPEG'],
    ['Künefe','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/K%C3%BCnefe.jpg/320px-K%C3%BCnefe.jpg'],
    ['Börek','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/B%C3%B6rek.jpg/320px-B%C3%B6rek.jpg'],
    ['Gözleme','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/G%C3%B6zleme.jpg/320px-G%C3%B6zleme.jpg'],
    ['Simit','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Simit_from_Istanbul.jpg/320px-Simit_from_Istanbul.jpg'],
    ['Mercimek Çorbası','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Mercimek_%C3%A7orbas%C4%B1.jpg/320px-Mercimek_%C3%A7orbas%C4%B1.jpg'],
    ['Menemen','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Menemen.jpg/320px-Menemen.jpg'],
    ['Cacık','https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cacik.jpg/320px-Cacik.jpg'],
    ['Hummus','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Hummus_from_The_Nile.jpg/320px-Hummus_from_The_Nile.jpg'],
    ['Ayran','https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Ayran.jpg/240px-Ayran.jpg'],
    ['Türkischer Tee','https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/A_small_cup_of_turkish_tea.jpg/240px-A_small_cup_of_turkish_tea.jpg'],
    ['Türkischer Kaffee','https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/A_small_cup_of_coffee.JPG/240px-A_small_cup_of_coffee.JPG'],
    ['Lokum','https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Turkish_delight.jpg/320px-Turkish_delight.jpg'],
    ['Kadayıf','https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Kadayif.jpg/320px-Kadayif.jpg'],
    ['Şekerpare','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/%C5%9Eekerpare.jpg/320px-%C5%9Eekerpare.jpg'],
    ['Yaprak Sarma','https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Dolmades.jpg/320px-Dolmades.jpg'],
    ['Sigara Böreği','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Sigara_borek.jpg/320px-Sigara_borek.jpg'],
    ['Kuru Fasulye','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Kuru_Fasulye.jpg/320px-Kuru_Fasulye.jpg'],
    ['Sucuklu Yumurta','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Sucuklu_yumurta.jpg/320px-Sucuklu_yumurta.jpg'],
    ['Helva','https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Turkish_halva.jpg/320px-Turkish_halva.jpg'],
    ['Hünkar Beğendi','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/H%C3%BCnkar_be%C4%9Fendi.jpg/320px-H%C3%BCnkar_be%C4%9Fendi.jpg'],
    ['Dondurma','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Dondurma.jpg/320px-Dondurma.jpg'],
  ];
  for (const [name, url] of tkItems) await addItem(name, essenId, tkId, url);

  // Italienische Küche
  const ikItems = [
    ['Pizza Margherita','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg/320px-Eq_it-na_pizza-margherita_sep2005_sml.jpg'],
    ['Spaghetti Carbonara','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Fresh_made_Pasta_Carbonara.jpg/320px-Fresh_made_Pasta_Carbonara.jpg'],
    ['Lasagne','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Lasagna_-_stonesoup.jpg/320px-Lasagna_-_stonesoup.jpg'],
    ['Risotto','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Risotto_black.jpg/320px-Risotto_black.jpg'],
    ['Tiramisu','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Tiramisu_-_Raffaele_Diomede.jpg/320px-Tiramisu_-_Raffaele_Diomede.jpg'],
    ['Gnocchi','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Gnocchi_di_patate.jpg/320px-Gnocchi_di_patate.jpg'],
    ['Bruschetta','https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Bruschetta_with_tomatoes.jpg/320px-Bruschetta_with_tomatoes.jpg'],
    ['Gelato','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Sundae_Supreme_%28cropped%29.jpg/240px-Sundae_Supreme_%28cropped%29.jpg'],
    ['Focaccia','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Focaccia_Recco.jpg/320px-Focaccia_Recco.jpg'],
    ['Panna Cotta','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Panna_cotta_with_strawberry_sauce.jpg/320px-Panna_cotta_with_strawberry_sauce.jpg'],
    ['Cannoli','https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cannoli.jpg/320px-Cannoli.jpg'],
    ['Ossobuco','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Ossobuco_di_vitello.jpg/320px-Ossobuco_di_vitello.jpg'],
  ];
  for (const [name, url] of ikItems) await addItem(name, essenId, ikId, url);

  // Japanische Küche
  const jkItems = [
    ['Sushi','https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Sushi_platter.jpg/320px-Sushi_platter.jpg'],
    ['Ramen','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Shoyu_Ramen.jpg/320px-Shoyu_Ramen.jpg'],
    ['Tempura','https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Tempura_Ebi.jpg/320px-Tempura_Ebi.jpg'],
    ['Tonkatsu','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Tonkatsu_with_miso_soup.jpg/320px-Tonkatsu_with_miso_soup.jpg'],
    ['Takoyaki','https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Takoyaki_01.jpg/320px-Takoyaki_01.jpg'],
    ['Yakitori','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Yakitori_2007.jpg/320px-Yakitori_2007.jpg'],
    ['Okonomiyaki','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Okonomiyaki_in_Kyoto.jpg/320px-Okonomiyaki_in_Kyoto.jpg'],
    ['Gyoza','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Gyoza_dumplings.jpg/320px-Gyoza_dumplings.jpg'],
    ['Mochi','https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Mochi-daifuku.jpg/320px-Mochi-daifuku.jpg'],
    ['Udon','https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Udon_by_stu_spivack_in_Flickr.jpg/320px-Udon_by_stu_spivack_in_Flickr.jpg'],
    ['Onigiri','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Onigiri.jpg/320px-Onigiri.jpg'],
    ['Miso Suppe','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Miso_Soup.jpg/320px-Miso_Soup.jpg'],
    ['Karaage','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Karaage.jpg/320px-Karaage.jpg'],
  ];
  for (const [name, url] of jkItems) await addItem(name, essenId, jkId, url);

  // Fast Food
  const ffItems = [
    ["McDonald's",'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/McDonald%27s_Golden_Arches.svg/240px-McDonald%27s_Golden_Arches.svg.png'],
    ['KFC','https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/KFC_logo-image.svg/240px-KFC_logo-image.svg.png'],
    ['Burger King','https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Burger_King_logo_%281999%29.svg/240px-Burger_King_logo_%281999%29.svg.png'],
    ['Subway','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Subway_2016_logo.svg/320px-Subway_2016_logo.svg.png'],
    ['Pizza Hut','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Pizza_Hut_logo.svg/320px-Pizza_Hut_logo.svg.png'],
    ["Domino's",'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Dominos_pizza_logo.svg/320px-Dominos_pizza_logo.svg.png'],
    ['Five Guys','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Five_Guys_logo.svg/320px-Five_Guys_logo.svg.png'],
    ['Chipotle','https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Chipotle_Mexican_Grill_logo.svg/320px-Chipotle_Mexican_Grill_logo.svg.png'],
    ["Wendy's",'https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Wendy%27s_full_logo_2012.svg/320px-Wendy%27s_full_logo_2012.svg.png'],
    ['Taco Bell','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Taco_Bell_Logo.svg/320px-Taco_Bell_Logo.svg.png'],
    ['Shake Shack','https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Shake_Shack_logo.svg/320px-Shake_Shack_logo.svg.png'],
  ];
  for (const [name, url] of ffItems) await addItem(name, essenId, ffId, url);

  // Desserts
  const desItems = [
    ['Tiramisu','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Tiramisu_-_Raffaele_Diomede.jpg/320px-Tiramisu_-_Raffaele_Diomede.jpg'],
    ['Cheesecake','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Cherry_cheesecake.jpg/320px-Cherry_cheesecake.jpg'],
    ['Eis','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Sundae_Supreme_%28cropped%29.jpg/240px-Sundae_Supreme_%28cropped%29.jpg'],
    ['Macarons','https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Assorted_French_macarons.jpg/320px-Assorted_French_macarons.jpg'],
    ['Donut','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Glazed-Donut.jpg/320px-Glazed-Donut.jpg'],
    ['Brownie','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Brownies_%28homemade%29.jpg/320px-Brownies_%28homemade%29.jpg'],
    ['Waffeln','https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Wafels_%26_Dinges_-_Wafels_4_%284751580440%29.jpg/320px-Wafels_%26_Dinges_-_Wafels_4_%284751580440%29.jpg'],
    ['Mochi','https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Mochi-daifuku.jpg/320px-Mochi-daifuku.jpg'],
    ['Crêpes','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Crepe_suette_g%C3%A2teau.jpg/320px-Crepe_suette_g%C3%A2teau.jpg'],
    ['Churros','https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Churros_-_Evan_Swigart.jpg/320px-Churros_-_Evan_Swigart.jpg'],
    ['Baklava','https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Baklava_-_Turkish_special%2C_80-ply.JPEG/320px-Baklava_-_Turkish_special%2C_80-ply.JPEG'],
    ['Panna Cotta','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Panna_cotta_with_strawberry_sauce.jpg/320px-Panna_cotta_with_strawberry_sauce.jpg'],
  ];
  for (const [name, url] of desItems) await addItem(name, essenId, desId, url);

  // ── FUSSBALL ─────────────────────────────────────────────────────────────
  const fussballId = await addCategory('Fußball');
  const blVId = await addCategory('Bundesliga', fussballId);
  const plVId = await addCategory('Premier League', fussballId);
  const laVId = await addCategory('La Liga', fussballId);
  const saVId = await addCategory('Serie A', fussballId);
  const l1VId = await addCategory('Ligue 1', fussballId);
  const allVId = await addCategory('Alle Top-Vereine', fussballId);
  const aktStId = await addCategory('Aktuelle Stars', fussballId);
  const legStId = await addCategory('Legenden', fussballId);
  const blStId = await addCategory('Bundesliga Stars', fussballId);
  const plStId = await addCategory('Premier League Stars', fussballId);
  const laStId = await addCategory('La Liga Stars', fussballId);

  const blVereine = [
    ['FC Bayern München','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282002%E2%80%932017%29.svg/240px-FC_Bayern_M%C3%BCnchen_logo_%282002%E2%80%932017%29.svg.png'],
    ['Borussia Dortmund','https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Borussia_Dortmund_logo.svg/240px-Borussia_Dortmund_logo.svg.png'],
    ['Bayer Leverkusen','https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Bayer_04_Leverkusen_logo.svg/240px-Bayer_04_Leverkusen_logo.svg.png'],
    ['RB Leipzig','https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/RB_Leipzig_2014_logo.svg/240px-RB_Leipzig_2014_logo.svg.png'],
    ['Eintracht Frankfurt','https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Eintracht_Frankfurt_Logo.svg/240px-Eintracht_Frankfurt_Logo.svg.png'],
    ['VfB Stuttgart','https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/VfB_Stuttgart_1893_Logo.svg/240px-VfB_Stuttgart_1893_Logo.svg.png'],
    ['Borussia Mönchengladbach','https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Borussia_M%C3%B6nchengladbach_logo.svg/240px-Borussia_M%C3%B6nchengladbach_logo.svg.png'],
    ['Werder Bremen','https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/SV-Werder-Bremen-Logo.svg/240px-SV-Werder-Bremen-Logo.svg.png'],
    ['SC Freiburg','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/SC_Freiburg_Logo.svg/240px-SC_Freiburg_Logo.svg.png'],
    ['Union Berlin','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/1._FC_Union_Berlin_Logo.svg/240px-1._FC_Union_Berlin_Logo.svg.png'],
    ['TSG Hoffenheim','https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/TSG_1899_Hoffenheim_logo.svg/240px-TSG_1899_Hoffenheim_logo.svg.png'],
    ['Hamburger SV','https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/HSV_Logo.svg/240px-HSV_Logo.svg.png'],
  ];
  for (const [name, url] of blVereine) await addItem(name, fussballId, blVId, url);

  const plVereine = [
    ['Manchester City','https://upload.wikimedia.org/wikipedia/en/thumb/e/eb/Manchester_City_FC_badge.svg/240px-Manchester_City_FC_badge.svg.png'],
    ['Arsenal','https://upload.wikimedia.org/wikipedia/en/thumb/5/53/Arsenal_FC.svg/240px-Arsenal_FC.svg.png'],
    ['Liverpool','https://upload.wikimedia.org/wikipedia/en/thumb/0/0c/Liverpool_FC.svg/240px-Liverpool_FC.svg.png'],
    ['Chelsea','https://upload.wikimedia.org/wikipedia/en/thumb/c/cc/Chelsea_FC.svg/240px-Chelsea_FC.svg.png'],
    ['Manchester United','https://upload.wikimedia.org/wikipedia/en/thumb/7/7a/Manchester_United_FC_crest.svg/240px-Manchester_United_FC_crest.svg.png'],
    ['Tottenham Hotspur','https://upload.wikimedia.org/wikipedia/en/thumb/b/b4/Tottenham_Hotspur.svg/240px-Tottenham_Hotspur.svg.png'],
    ['Newcastle United','https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Newcastle_United_Logo.svg/240px-Newcastle_United_Logo.svg.png'],
    ['Aston Villa','https://upload.wikimedia.org/wikipedia/en/thumb/f/f9/Aston_Villa_FC_crest_%282016%29.svg/240px-Aston_Villa_FC_crest_%282016%29.svg.png'],
    ['West Ham United','https://upload.wikimedia.org/wikipedia/en/thumb/c/c2/West_Ham_United_FC_logo.svg/240px-West_Ham_United_FC_logo.svg.png'],
    ['Brighton','https://upload.wikimedia.org/wikipedia/en/thumb/f/fd/Brighton_%26_Hove_Albion_logo.svg/240px-Brighton_%26_Hove_Albion_logo.svg.png'],
    ['Everton','https://upload.wikimedia.org/wikipedia/en/thumb/7/7c/Everton_FC_logo.svg/240px-Everton_FC_logo.svg.png'],
    ['Nottingham Forest','https://upload.wikimedia.org/wikipedia/en/thumb/e/e5/Nottingham_Forest_F.C._logo.svg/240px-Nottingham_Forest_F.C._logo.svg.png'],
  ];
  for (const [name, url] of plVereine) await addItem(name, fussballId, plVId, url);

  const laVereine = [
    ['Real Madrid','https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Real_Madrid_CF.svg/240px-Real_Madrid_CF.svg.png'],
    ['FC Barcelona','https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/240px-FC_Barcelona_%28crest%29.svg.png'],
    ['Atletico Madrid','https://upload.wikimedia.org/wikipedia/en/thumb/f/f4/Atletico_Madrid_2017_logo.svg/240px-Atletico_Madrid_2017_logo.svg.png'],
    ['Sevilla FC','https://upload.wikimedia.org/wikipedia/en/thumb/3/3b/Sevilla_FC_logo.svg/240px-Sevilla_FC_logo.svg.png'],
    ['Real Sociedad','https://upload.wikimedia.org/wikipedia/en/thumb/f/f1/Real_Sociedad_logo.svg/240px-Real_Sociedad_logo.svg.png'],
    ['Villarreal','https://upload.wikimedia.org/wikipedia/en/thumb/b/b9/Villarreal_CF_logo-en.svg/240px-Villarreal_CF_logo-en.svg.png'],
    ['Athletic Bilbao','https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Club_Athletic_de_Bilbao_logo.svg/240px-Club_Athletic_de_Bilbao_logo.svg.png'],
    ['Valencia CF','https://upload.wikimedia.org/wikipedia/en/thumb/c/ce/Valenciacf.svg/240px-Valenciacf.svg.png'],
    ['Real Betis','https://upload.wikimedia.org/wikipedia/en/thumb/1/13/Real_betis_logo.svg/240px-Real_betis_logo.svg.png'],
    ['Girona FC','https://upload.wikimedia.org/wikipedia/en/thumb/2/24/Girona_FC_logo.svg/240px-Girona_FC_logo.svg.png'],
  ];
  for (const [name, url] of laVereine) await addItem(name, fussballId, laVId, url);

  const saVereine = [
    ['Inter Mailand','https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/FC_Internazionale_Milano_2021.svg/240px-FC_Internazionale_Milano_2021.svg.png'],
    ['AC Mailand','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Logo_of_AC_Milan.svg/240px-Logo_of_AC_Milan.svg.png'],
    ['Juventus','https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Juventus_FC_2017_logo.svg/240px-Juventus_FC_2017_logo.svg.png'],
    ['Napoli','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/SSC_Napoli.svg/240px-SSC_Napoli.svg.png'],
    ['AS Roma','https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/AS_Roma_logo_%282013%29.svg/240px-AS_Roma_logo_%282013%29.svg.png'],
    ['Lazio','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/SS_Lazio_Badge.svg/240px-SS_Lazio_Badge.svg.png'],
    ['Fiorentina','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/ACF_Fiorentina.svg/240px-ACF_Fiorentina.svg.png'],
    ['Atalanta','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/AtalantaBC.svg/240px-AtalantaBC.svg.png'],
    ['Bologna','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Bologna_F.C._1909_logo.svg/240px-Bologna_F.C._1909_logo.svg.png'],
    ['Torino','https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Torino_FC_Logo.svg/240px-Torino_FC_Logo.svg.png'],
  ];
  for (const [name, url] of saVereine) await addItem(name, fussballId, saVId, url);

  const aktSpieler = [
    ['Erling Haaland','https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Erling_Haaland%2C_Man_City_vs_West_Ham_%28cropped%29.jpg/240px-Erling_Haaland%2C_Man_City_vs_West_Ham_%28cropped%29.jpg'],
    ['Kylian Mbappé','https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/2019-07-17_SG_Dynamo_Dresden_vs._Paris_Saint-Germain_by_Sandro_Halank%E2%80%93049_%28cropped%29.jpg/240px-2019-07-17_SG_Dynamo_Dresden_vs._Paris_Saint-Germain_by_Sandro_Halank%E2%80%93049_%28cropped%29.jpg'],
    ['Vinicius Jr.','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Vinicius_Jr_2022_%28cropped%29.jpg/240px-Vinicius_Jr_2022_%28cropped%29.jpg'],
    ['Jude Bellingham','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Jude_Bellingham_2023_%28cropped%29.jpg/240px-Jude_Bellingham_2023_%28cropped%29.jpg'],
    ['Lionel Messi','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg/240px-Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg'],
    ['Cristiano Ronaldo','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cristiano_Ronaldo_2018_%28cropped%29.jpg/240px-Cristiano_Ronaldo_2018_%28cropped%29.jpg'],
    ['Mohamed Salah','https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Mohamed_Salah_2018_%28cropped%29.jpg/240px-Mohamed_Salah_2018_%28cropped%29.jpg'],
    ['Harry Kane','https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Harry_Kane_2022_%28cropped%29.jpg/240px-Harry_Kane_2022_%28cropped%29.jpg'],
    ['Kevin De Bruyne','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Kevin_De_Bruyne_2018_%28cropped%29.jpg/240px-Kevin_De_Bruyne_2018_%28cropped%29.jpg'],
    ['Phil Foden','https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Phil_Foden_%28cropped%29.jpg/240px-Phil_Foden_%28cropped%29.jpg'],
    ['Pedri','https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Pedri_%28cropped%29.jpg/240px-Pedri_%28cropped%29.jpg'],
    ['Lamine Yamal','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Lamine_Yamal_2024_%28cropped%29.jpg/240px-Lamine_Yamal_2024_%28cropped%29.jpg'],
    ['Florian Wirtz','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Florian_Wirtz_2023_%28cropped%29.jpg/240px-Florian_Wirtz_2023_%28cropped%29.jpg'],
    ['Jamal Musiala','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Jamal_Musiala_2022_%28cropped%29.jpg/240px-Jamal_Musiala_2022_%28cropped%29.jpg'],
    ['Bukayo Saka','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Bukayo_Saka_%28cropped%29.jpg/240px-Bukayo_Saka_%28cropped%29.jpg'],
    ['Gavi','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Gavi_%28cropped%29.jpg/240px-Gavi_%28cropped%29.jpg'],
    ['Rodri','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Rodri_%28cropped%29.jpg/240px-Rodri_%28cropped%29.jpg'],
    ['Toni Kroos','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Toni_Kroos_2018_%28cropped%29.jpg/240px-Toni_Kroos_2018_%28cropped%29.jpg'],
    ['Joshua Kimmich','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Joshua_Kimmich_2018_%28cropped%29.jpg/240px-Joshua_Kimmich_2018_%28cropped%29.jpg'],
    ['Lautaro Martinez','https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Lautaro_Martinez_2022_%28cropped%29.jpg/240px-Lautaro_Martinez_2022_%28cropped%29.jpg'],
    ['Declan Rice','https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Declan_Rice_2023_%28cropped%29.jpg/240px-Declan_Rice_2023_%28cropped%29.jpg'],
    ['Cole Palmer','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Cole_Palmer_2023_%28cropped%29.jpg/240px-Cole_Palmer_2023_%28cropped%29.jpg'],
    ['Robert Lewandowski','https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Robert_Lewandowski%2C_FC_Bayern_M%C3%BCnchen_%28by_Augustas_Didzgalvis%29_%28cropped%29.jpg/240px-Robert_Lewandowski%2C_FC_Bayern_M%C3%BCnchen_%28by_Augustas_Didzgalvis%29_%28cropped%29.jpg'],
    ['Neymar Jr.','https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Neymar_2022_%28cropped%29.jpg/240px-Neymar_2022_%28cropped%29.jpg'],
  ];
  for (const [name, url] of aktSpieler) await addItem(name, fussballId, aktStId, url);

  const legenden = [
    ['Pelé','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Pel%C3%A9_1970.jpg/240px-Pel%C3%A9_1970.jpg'],
    ['Diego Maradona','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Maradona-Mundial_86_con_la_copa.JPG/240px-Maradona-Mundial_86_con_la_copa.JPG'],
    ['Zinedine Zidane','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Zinedine_Zidane_by_Tasnim_03.jpg/240px-Zinedine_Zidane_by_Tasnim_03.jpg'],
    ['Ronaldo R9','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Ronaldo_Penta_Balon_de_oro.jpg/240px-Ronaldo_Penta_Balon_de_oro.jpg'],
    ['Ronaldinho','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Ronaldinho_2018.jpg/240px-Ronaldinho_2018.jpg'],
    ['Thierry Henry','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Thierry_Henry_2012.jpg/240px-Thierry_Henry_2012.jpg'],
    ['Franz Beckenbauer','https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Franz_Beckenbauer_-_1966_%28cropped%29.jpg/240px-Franz_Beckenbauer_-_1966_%28cropped%29.jpg'],
    ['Johan Cruyff','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Johan_Cruyff%2C_1974_%28cropped%29.jpg/240px-Johan_Cruyff%2C_1974_%28cropped%29.jpg'],
    ['Paolo Maldini','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Paolo_Maldini_%28cropped%29.jpg/240px-Paolo_Maldini_%28cropped%29.jpg'],
    ['David Beckham','https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/David_Beckham_2013_%28cropped%29.jpg/240px-David_Beckham_2013_%28cropped%29.jpg'],
    ['Gerd Müller','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Gerd_M%C3%BCller_1974_%28cropped%29.jpg/240px-Gerd_M%C3%BCller_1974_%28cropped%29.jpg'],
    ['Roberto Carlos','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Roberto_Carlos_2012_%28cropped%29.jpg/240px-Roberto_Carlos_2012_%28cropped%29.jpg'],
    ['Miroslav Klose','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Miroslav_Klose_2014_%28cropped%29.jpg/240px-Miroslav_Klose_2014_%28cropped%29.jpg'],
    ['Lev Yashin','https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Lev_Yashin_1960.jpg/240px-Lev_Yashin_1960.jpg'],
    ['George Best','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/George_Best_1971_%28cropped%29.jpg/240px-George_Best_1971_%28cropped%29.jpg'],
  ];
  for (const [name, url] of legenden) await addItem(name, fussballId, legStId, url);

  // ── BOXEN ────────────────────────────────────────────────────────────────
  const boxenId = await addCategory('Boxen');
  const bxAlleId = await addCategory('Alle Boxer', boxenId);
  const bxSgId = await addCategory('Schwergewicht', boxenId);
  const bxMgId = await addCategory('Mittelgewicht', boxenId);
  const bxLegId = await addCategory('Legenden', boxenId);
  const bxAkId = await addCategory('Aktuelle Champions', boxenId);
  const bxDeId = await addCategory('Deutsche Boxer', boxenId);

  const alleBoxer = [
    ['Muhammad Ali','https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Muhammad_Ali_NYWTS.jpg/240px-Muhammad_Ali_NYWTS.jpg'],
    ['Mike Tyson','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Mike_Tyson_2019.jpg/240px-Mike_Tyson_2019.jpg'],
    ['Floyd Mayweather','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Floyd_Mayweather_Jr_2015.jpg/240px-Floyd_Mayweather_Jr_2015.jpg'],
    ['Manny Pacquiao','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Manny_Pacquiao_2019.jpg/240px-Manny_Pacquiao_2019.jpg'],
    ['Tyson Fury','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Tyson_Fury_2018.jpg/240px-Tyson_Fury_2018.jpg'],
    ['Oleksandr Usyk','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Oleksandr_Usyk_2019.jpg/240px-Oleksandr_Usyk_2019.jpg'],
    ['Anthony Joshua','https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Anthony_Joshua_2019.jpg/240px-Anthony_Joshua_2019.jpg'],
    ['Saul Canelo Alvarez','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Canelo_Alvarez_2019.jpg/240px-Canelo_Alvarez_2019.jpg'],
    ['Wladimir Klitschko','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Wladimir_Klitschko_2013.jpg/240px-Wladimir_Klitschko_2013.jpg'],
    ['Vitali Klitschko','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Vitali_Klitschko_2013.jpg/240px-Vitali_Klitschko_2013.jpg'],
    ['George Foreman','https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/George_Foreman_2009.jpg/240px-George_Foreman_2009.jpg'],
    ['Evander Holyfield','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Evander_Holyfield_2012.jpg/240px-Evander_Holyfield_2012.jpg'],
    ['Lennox Lewis','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Lennox_Lewis_2010.jpg/240px-Lennox_Lewis_2010.jpg'],
    ['Gennady Golovkin','https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Gennady_Golovkin_2017.jpg/240px-Gennady_Golovkin_2017.jpg'],
    ['Sugar Ray Robinson','https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Sugar_Ray_Robinson.jpg/240px-Sugar_Ray_Robinson.jpg'],
    ['Rocky Marciano','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Rocky_Marciano.jpg/240px-Rocky_Marciano.jpg'],
    ['Joe Frazier','https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Joe_Frazier_1971.jpg/240px-Joe_Frazier_1971.jpg'],
    ['Ryan Garcia','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Ryan_Garcia_2022.jpg/240px-Ryan_Garcia_2022.jpg'],
  ];
  for (const [name, url] of alleBoxer) {
    await addItem(name, boxenId, bxAlleId, url);
    await addItem(name, boxenId, bxSgId, url);
    await addItem(name, boxenId, bxLegId, url);
  }

  // ── ORTE ─────────────────────────────────────────────────────────────────
  const orteId = await addCategory('Orte');
  const stId = await addCategory('Städte', orteId);
  const laId = await addCategory('Länder', orteId);
  const sehId = await addCategory('Sehenswürdigkeiten', orteId);
  const strId = await addCategory('Strände', orteId);
  const bergeId = await addCategory('Berge', orteId);
  const inselId = await addCategory('Inseln', orteId);

  const staedte = [
    ['Tokio','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Skyscrapers_of_Shinjuku_2009_January.jpg/320px-Skyscrapers_of_Shinjuku_2009_January.jpg'],
    ['New York','https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/New_york_times_square-terabass.jpg/320px-New_york_times_square-terabass.jpg'],
    ['Paris','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Tour_Eiffel_Wikimedia_Commons.jpg/240px-Tour_Eiffel_Wikimedia_Commons.jpg'],
    ['London','https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/London_Skyline_%28125508655%29.jpeg/320px-London_Skyline_%28125508655%29.jpeg'],
    ['Dubai','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Dubai_Skyline_UAE.jpg/320px-Dubai_Skyline_UAE.jpg'],
    ['Berlin','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Brandenburger_Tor_abends.jpg/320px-Brandenburger_Tor_abends.jpg'],
    ['Barcelona','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Sagrada_Familia_01.jpg/320px-Sagrada_Familia_01.jpg'],
    ['Rom','https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Colosseo_2020.jpg/320px-Colosseo_2020.jpg'],
    ['Sydney','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Sydney_Australia._%2821339175489%29.jpg/320px-Sydney_Australia._%2821339175489%29.jpg'],
    ['Singapur','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Singapore_Skyline_at_Blue_Hour_%28Explored%29_%2825367558364%29.jpg/320px-Singapore_Skyline_at_Blue_Hour_%28Explored%29_%2825367558364%29.jpg'],
    ['Istanbul','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Istanbul_Skyline_Bosporus.jpg/320px-Istanbul_Skyline_Bosporus.jpg'],
    ['München','https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Muenchen_Rathaus.jpg/320px-Muenchen_Rathaus.jpg'],
    ['Rio de Janeiro','https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Aerial_view_of_Centro%2C_Rio_de_Janeiro%2C_July_2019.jpg/320px-Aerial_view_of_Centro%2C_Rio_de_Janeiro%2C_July_2019.jpg'],
    ['Amsterdam','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Amsterdam_-_panoramio_%28105%29.jpg/320px-Amsterdam_-_panoramio_%28105%29.jpg'],
    ['Wien','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Schoenbrunn_front_02.jpg/320px-Schoenbrunn_front_02.jpg'],
    ['Los Angeles','https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/20041026_Hollywood_Sign.jpg/320px-20041026_Hollywood_Sign.jpg'],
    ['Bangkok','https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Wat_Phra_Kaew_temple.jpg/320px-Wat_Phra_Kaew_temple.jpg'],
    ['Moskau','https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/St._Basil%27s_Cathedral_and_Red_Square.jpg/320px-St._Basil%27s_Cathedral_and_Red_Square.jpg'],
  ];
  for (const [name, url] of staedte) await addItem(name, orteId, stId, url);

  const sehenswuerdigkeiten = [
    ['Eiffelturm','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Tour_Eiffel_Wikimedia_Commons.jpg/240px-Tour_Eiffel_Wikimedia_Commons.jpg'],
    ['Kolosseum','https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Colosseo_2020.jpg/320px-Colosseo_2020.jpg'],
    ['Big Ben','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Clock_Tower_-_Palace_of_Westminster%2C_London_-_May_2007_icon.png/240px-Clock_Tower_-_Palace_of_Westminster%2C_London_-_May_2007_icon.png'],
    ['Sagrada Família','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Sagrada_Familia_01.jpg/320px-Sagrada_Familia_01.jpg'],
    ['Taj Mahal','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Taj_Mahal_%28Edited%29.jpeg/320px-Taj_Mahal_%28Edited%29.jpeg'],
    ['Machu Picchu','https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Machu_Picchu%2C_Peru.jpg/320px-Machu_Picchu%2C_Peru.jpg'],
    ['Chinesische Mauer','https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/The_Great_Wall_of_China_at_Jinshanling-edit.jpg/320px-The_Great_Wall_of_China_at_Jinshanling-edit.jpg'],
    ['Burj Khalifa','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Burj_Khalifa.jpg/240px-Burj_Khalifa.jpg'],
    ['Niagara Falls','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Niagara_Falls_2010_%2814%29.jpg/320px-Niagara_Falls_2010_%2814%29.jpg'],
    ['Pyramiden von Gizeh','https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/All_Gizah_Pyramids.jpg/320px-All_Gizah_Pyramids.jpg'],
    ['Stonehenge','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Stonehenge2007_07_30.jpg/320px-Stonehenge2007_07_30.jpg'],
    ['Alhambra','https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Alhambra_granada_spain.jpeg/320px-Alhambra_granada_spain.jpeg'],
  ];
  for (const [name, url] of sehenswuerdigkeiten) await addItem(name, orteId, sehId, url);

  const laender = [
    ['Japan','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Flag_of_Japan.svg/320px-Flag_of_Japan.svg.png'],
    ['USA','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_the_United_States.svg/320px-Flag_of_the_United_States.svg.png'],
    ['Deutschland','https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Flag_of_Germany.svg/320px-Flag_of_Germany.svg.png'],
    ['Italien','https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Flag_of_Italy.svg/320px-Flag_of_Italy.svg.png'],
    ['Frankreich','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Flag_of_France.svg/320px-Flag_of_France.svg.png'],
    ['Spanien','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Flag_of_Spain.svg/320px-Flag_of_Spain.svg.png'],
    ['Brasilien','https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Flag_of_Brazil.svg/320px-Flag_of_Brazil.svg.png'],
    ['Australien','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Flag_of_Australia.svg/320px-Flag_of_Australia.svg.png'],
    ['Kanada','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Flag_of_Canada_%28Pantone%29.svg/320px-Flag_of_Canada_%28Pantone%29.svg.png'],
    ['Türkei','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Flag_of_Turkey.svg/320px-Flag_of_Turkey.svg.png'],
    ['Schweiz','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Flag_of_Switzerland.svg/240px-Flag_of_Switzerland.svg.png'],
    ['Österreich','https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Flag_of_Austria.svg/320px-Flag_of_Austria.svg.png'],
    ['Griechenland','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Greece.svg/320px-Flag_of_Greece.svg.png'],
    ['Thailand','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Flag_of_Thailand.svg/320px-Flag_of_Thailand.svg.png'],
    ['Mexiko','https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Flag_of_Mexico.svg/320px-Flag_of_Mexico.svg.png'],
  ];
  for (const [name, url] of laender) await addItem(name, orteId, laId, url);

  // ── SPORTARTEN ────────────────────────────────────────────────────────────
  const sportId = await addCategory('Sportarten');
  const balId = await addCategory('Ballsport', sportId);
  const kamId = await addCategory('Kampfsport', sportId);
  const wasId = await addCategory('Wassersport', sportId);
  const winId = await addCategory('Wintersport', sportId);
  const motId = await addCategory('Motorsport', sportId);
  const extId = await addCategory('Extremsport', sportId);

  const ballsport = [
    ['Fußball','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Soccerball.svg/240px-Soccerball.svg.png'],
    ['Basketball','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Basketball.png/240px-Basketball.png'],
    ['Tennis','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image-Tennis-Racket-and-Balls.jpg/320px-Image-Tennis-Racket-and-Balls.jpg'],
    ['Volleyball','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Volleyball_court2.svg/320px-Volleyball_court2.svg.png'],
    ['American Football','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/American_football_300ppx.jpg/240px-American_football_300ppx.jpg'],
    ['Rugby','https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Sport_rugby.svg/240px-Sport_rugby.svg.png'],
    ['Golf','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Golf_ball.jpg/240px-Golf_ball.jpg'],
    ['Handball','https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Handball_Pictogram.svg/240px-Handball_Pictogram.svg.png'],
    ['Tischtennis','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Table_tennis_pictogram.svg/240px-Table_tennis_pictogram.svg.png'],
    ['Baseball','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Baseball_Pictogram.svg/240px-Baseball_Pictogram.svg.png'],
    ['Cricket','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Cricket_pictogram.svg/240px-Cricket_pictogram.svg.png'],
  ];
  for (const [name, url] of ballsport) await addItem(name, sportId, balId, url);

  const kampfsport = [
    ['Boxen','https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Boxing_pictogram.svg/240px-Boxing_pictogram.svg.png'],
    ['MMA','https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/MMA_mixed_martial_arts.jpg/320px-MMA_mixed_martial_arts.jpg'],
    ['Judo','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Judo_pictogram.svg/240px-Judo_pictogram.svg.png'],
    ['Karate','https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Karate_pictogram.svg/240px-Karate_pictogram.svg.png'],
    ['Taekwondo','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Taekwondo_pictogram.svg/240px-Taekwondo_pictogram.svg.png'],
    ['Ringen','https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Wrestling_pictogram.svg/240px-Wrestling_pictogram.svg.png'],
    ['Muay Thai','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Muay_thai_2.jpg/320px-Muay_thai_2.jpg'],
    ['Sumo','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Sumo_wrestling.jpg/320px-Sumo_wrestling.jpg'],
    ['BJJ','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Judo_pictogram.svg/240px-Judo_pictogram.svg.png'],
    ['Kickboxen','https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Boxing_pictogram.svg/240px-Boxing_pictogram.svg.png'],
  ];
  for (const [name, url] of kampfsport) await addItem(name, sportId, kamId, url);

  const motorsport = [
    ['Formel 1','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/F1.svg/320px-F1.svg.png'],
    ['MotoGP','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Motorcycle_racing_pictogram.svg/240px-Motorcycle_racing_pictogram.svg.png'],
    ['NASCAR','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/NASCAR_logo.svg/320px-NASCAR_logo.svg.png'],
    ['Rally','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Rally_car.jpg/320px-Rally_car.jpg'],
    ['Le Mans','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/24h_Le_Mans_logo.svg/320px-24h_Le_Mans_logo.svg.png'],
    ['DTM','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/DTM_logo.svg/320px-DTM_logo.svg.png'],
  ];
  for (const [name, url] of motorsport) await addItem(name, sportId, motId, url);

  console.log('✅ Seed complete!');
  process.exit(0);
}

seed().catch(err => { console.error('❌ Error:', err); process.exit(1); });
