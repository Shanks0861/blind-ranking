const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function fixAll() {
  console.log('🔍 Lade alle Kategorien...');
  const allCats = await db.collection('categories').get();
  const catByName = {};
  allCats.docs.forEach(d => { catByName[d.data().name] = { id: d.id, parentId: d.data().parent_id }; });

  console.log('🗑️  Lösche alle Items...');
  const items = await db.collection('items').get();
  let batch = db.batch(); let count = 0;
  for (const doc of items.docs) {
    batch.delete(doc.ref); count++;
    if (count % 400 === 0) { await batch.commit(); batch = db.batch(); }
  }
  await batch.commit();
  console.log(`✅ ${count} Items gelöscht`);

  async function add(catName, subName, items) {
    const cat = catByName[catName];
    const sub = catByName[subName];
    if (!cat) { console.log('❌ Kat nicht gefunden:', catName); return 0; }
    if (!sub) { console.log('❌ Sub nicht gefunden:', subName); return 0; }
    let b = db.batch(); let c = 0;
    for (const [name, url] of items) {
      const ref = db.collection('items').doc();
      b.set(ref, { name, category_id: cat.id, sub_category_id: sub.id, image_url: url || null });
      c++;
      if (c % 400 === 0) { await b.commit(); b = db.batch(); }
    }
    await b.commit();
    return c;
  }

  let total = 0;

  // ═══════════════════════════════════════════════════════════
  // ANIME — Beliebteste (Anime-Cover von MAL via weserv — funktioniert!)
  // ═══════════════════════════════════════════════════════════
  total += await add('Anime','Beliebteste Animes',[
    ['One Piece','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Naruto','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Dragon Ball Z','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/43049.jpg&w=200&h=280&fit=cover'],
    ['Attack on Titan','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/10/47347.jpg&w=200&h=280&fit=cover'],
    ['Death Note','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/9/9453.jpg&w=200&h=280&fit=cover'],
    ['Fullmetal Alchemist: Brotherhood','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/1223/96541.jpg&w=200&h=280&fit=cover'],
    ['Demon Slayer','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/1286/99889.jpg&w=200&h=280&fit=cover'],
    ['Hunter x Hunter','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/11/33657.jpg&w=200&h=280&fit=cover'],
    ['Sword Art Online','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/11/39717.jpg&w=200&h=280&fit=cover'],
    ['My Hero Academia','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/10/78745.jpg&w=200&h=280&fit=cover'],
    ['Fairy Tail','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/7/25022.jpg&w=200&h=280&fit=cover'],
    ['Bleach','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/3/40451.jpg&w=200&h=280&fit=cover'],
    ['Tokyo Ghoul','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/5/64449.jpg&w=200&h=280&fit=cover'],
    ['Jujutsu Kaisen','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/1171/109222.jpg&w=200&h=280&fit=cover'],
    ['Vinland Saga','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/1500/103005.jpg&w=200&h=280&fit=cover'],
    ['Re:Zero','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/11/79410.jpg&w=200&h=280&fit=cover'],
    ['Black Clover','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/2/88336.jpg&w=200&h=280&fit=cover'],
    ['Steins;Gate','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/5/73199.jpg&w=200&h=280&fit=cover'],
    ['Overlord','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/7/88924.jpg&w=200&h=280&fit=cover'],
    ['Cowboy Bebop','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/4/19644.jpg&w=200&h=280&fit=cover'],
    ['Mob Psycho 100','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/8/80356.jpg&w=200&h=280&fit=cover'],
    ['Violet Evergarden','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/1795/95088.jpg&w=200&h=280&fit=cover'],
    ['Chainsaw Man','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/1806/126216.jpg&w=200&h=280&fit=cover'],
    ['Spy x Family','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/1441/122795.jpg&w=200&h=280&fit=cover'],
  ]); console.log('✅ Beliebteste Animes');

  // Für alle Anime-Charaktere nutzen wir Wikipedia-Bilder wo möglich,
  // sonst Wikimedia Commons oder neutrale Placeholder-URLs

  // ── DRAGON BALL ─────────────────────────────────────────────────────
  total += await add('Anime','Dragon Ball',[
    ['Goku','https://upload.wikimedia.org/wikipedia/en/thumb/5/5b/Goku_Dragon_Ball_Z.png/220px-Goku_Dragon_Ball_Z.png'],
    ['Vegeta','https://upload.wikimedia.org/wikipedia/en/thumb/4/4f/Vegeta_Dragon_Ball_FighterZ.png/220px-Vegeta_Dragon_Ball_FighterZ.png'],
    ['Gohan','https://upload.wikimedia.org/wikipedia/en/thumb/8/88/Son_Gohan.png/220px-Son_Gohan.png'],
    ['Piccolo','https://upload.wikimedia.org/wikipedia/en/thumb/0/07/Piccolo_DB_Artwork.png/220px-Piccolo_DB_Artwork.png'],
    ['Frieza','https://upload.wikimedia.org/wikipedia/en/thumb/b/bf/Frieza_DB_Artwork.png/220px-Frieza_DB_Artwork.png'],
    ['Cell','https://upload.wikimedia.org/wikipedia/en/thumb/1/18/Cell_DBZ_Artwork.png/220px-Cell_DBZ_Artwork.png'],
    ['Majin Buu','https://upload.wikimedia.org/wikipedia/en/thumb/e/ea/Majin_Boo_artwork.png/220px-Majin_Boo_artwork.png'],
    ['Trunks','https://upload.wikimedia.org/wikipedia/en/thumb/7/79/Future_Trunks.png/220px-Future_Trunks.png'],
    ['Broly','https://upload.wikimedia.org/wikipedia/en/thumb/5/53/Broly_%28Dragon_Ball_Super%29.png/220px-Broly_%28Dragon_Ball_Super%29.png'],
    ['Beerus','https://upload.wikimedia.org/wikipedia/en/thumb/1/1a/Beerus_Dragon_Ball.png/220px-Beerus_Dragon_Ball.png'],
    ['Krillin','https://upload.wikimedia.org/wikipedia/en/thumb/f/fd/Krillin_Dragon_Ball.png/220px-Krillin_Dragon_Ball.png'],
    ['Android 18','https://upload.wikimedia.org/wikipedia/en/thumb/0/06/Android18.png/220px-Android18.png'],
    ['Gogeta','https://upload.wikimedia.org/wikipedia/en/thumb/3/3d/Gogeta_Dragon_Ball.png/220px-Gogeta_Dragon_Ball.png'],
    ['Vegito','https://upload.wikimedia.org/wikipedia/en/thumb/e/ec/Vegito.png/220px-Vegito.png'],
    ['Jiren','https://upload.wikimedia.org/wikipedia/en/thumb/3/36/Jiren_Dragon_Ball_Super.png/220px-Jiren_Dragon_Ball_Super.png'],
    ['Goten','https://upload.wikimedia.org/wikipedia/en/thumb/d/dc/Goten_Dragon_Ball_Z.png/220px-Goten_Dragon_Ball_Z.png'],
    ['Bulma','https://upload.wikimedia.org/wikipedia/en/thumb/c/cc/Bulma_Dragon_Ball.png/220px-Bulma_Dragon_Ball.png'],
    ['Whis','https://upload.wikimedia.org/wikipedia/en/thumb/b/b0/Whis_Dragon_Ball_Z.png/220px-Whis_Dragon_Ball_Z.png'],
  ]); console.log('✅ Dragon Ball');

  // ── DEMON SLAYER ────────────────────────────────────────────────────
  total += await add('Anime','Demon Slayer',[
    ['Tanjiro Kamado','https://upload.wikimedia.org/wikipedia/en/thumb/b/b1/Tanjiro_Kamado.png/220px-Tanjiro_Kamado.png'],
    ['Nezuko Kamado','https://upload.wikimedia.org/wikipedia/en/thumb/7/74/Nezuko_Kamado.png/220px-Nezuko_Kamado.png'],
    ['Zenitsu Agatsuma','https://upload.wikimedia.org/wikipedia/en/thumb/3/3c/Zenitsu_Agatsuma.png/220px-Zenitsu_Agatsuma.png'],
    ['Inosuke Hashibira','https://upload.wikimedia.org/wikipedia/en/thumb/b/bd/Inosuke_Hashibira.png/220px-Inosuke_Hashibira.png'],
    ['Giyu Tomioka','https://upload.wikimedia.org/wikipedia/en/thumb/e/e5/Giyu_Tomioka.png/220px-Giyu_Tomioka.png'],
    ['Shinobu Kocho','https://upload.wikimedia.org/wikipedia/en/thumb/d/db/Shinobu_Kocho.png/220px-Shinobu_Kocho.png'],
    ['Rengoku Kyojuro','https://upload.wikimedia.org/wikipedia/en/thumb/e/e0/Kyojuro_Rengoku.png/220px-Kyojuro_Rengoku.png'],
    ['Tengen Uzui','https://upload.wikimedia.org/wikipedia/en/thumb/8/82/Tengen_Uzui.png/220px-Tengen_Uzui.png'],
    ['Muzan Kibutsuji','https://upload.wikimedia.org/wikipedia/en/thumb/b/b8/Muzan_Kibutsuji.png/220px-Muzan_Kibutsuji.png'],
    ['Akaza','https://upload.wikimedia.org/wikipedia/en/thumb/3/3d/Akaza_Demon_Slayer.png/220px-Akaza_Demon_Slayer.png'],
    ['Doma','https://upload.wikimedia.org/wikipedia/en/thumb/2/26/Doma_Demon_Slayer.png/220px-Doma_Demon_Slayer.png'],
    ['Kokushibo','https://upload.wikimedia.org/wikipedia/en/thumb/e/e8/Kokushibo_Demon_Slayer.png/220px-Kokushibo_Demon_Slayer.png'],
    ['Kanao Tsuyuri','https://upload.wikimedia.org/wikipedia/en/thumb/c/c0/Kanao_Tsuyuri.png/220px-Kanao_Tsuyuri.png'],
    ['Mitsuri Kanroji','https://upload.wikimedia.org/wikipedia/en/thumb/d/d1/Mitsuri_Kanroji.png/220px-Mitsuri_Kanroji.png'],
    ['Yoriichi Tsugikuni','https://upload.wikimedia.org/wikipedia/en/thumb/8/84/Yoriichi_Tsugikuni.png/220px-Yoriichi_Tsugikuni.png'],
  ]); console.log('✅ Demon Slayer');

  // ── ATTACK ON TITAN ─────────────────────────────────────────────────
  total += await add('Anime','Attack on Titan',[
    ['Eren Yeager','https://upload.wikimedia.org/wikipedia/en/thumb/e/e0/Eren_Yeager.png/220px-Eren_Yeager.png'],
    ['Mikasa Ackerman','https://upload.wikimedia.org/wikipedia/en/thumb/a/a4/Mikasa_Ackerman.png/220px-Mikasa_Ackerman.png'],
    ['Armin Arlert','https://upload.wikimedia.org/wikipedia/en/thumb/3/37/Armin_Arlelt.png/220px-Armin_Arlelt.png'],
    ['Levi Ackerman','https://upload.wikimedia.org/wikipedia/en/thumb/9/97/Levi_Ackermann.png/220px-Levi_Ackermann.png'],
    ['Hange Zoë','https://upload.wikimedia.org/wikipedia/en/thumb/0/04/Hange_Zo%C3%AB.png/220px-Hange_Zo%C3%AB.png'],
    ['Erwin Smith','https://upload.wikimedia.org/wikipedia/en/thumb/c/c6/Erwin_Smith.png/220px-Erwin_Smith.png'],
    ['Reiner Braun','https://upload.wikimedia.org/wikipedia/en/thumb/7/7e/Reiner_Braun.png/220px-Reiner_Braun.png'],
    ['Annie Leonhart','https://upload.wikimedia.org/wikipedia/en/thumb/e/e7/Annie_Leonhart.png/220px-Annie_Leonhart.png'],
    ['Zeke Yeager','https://upload.wikimedia.org/wikipedia/en/thumb/6/6c/Zeke_Yeager.png/220px-Zeke_Yeager.png'],
    ['Historia Reiss','https://upload.wikimedia.org/wikipedia/en/thumb/e/e1/Historia_Reiss.png/220px-Historia_Reiss.png'],
    ['Jean Kirstein','https://upload.wikimedia.org/wikipedia/en/thumb/3/38/Jean_Kirschtein.png/220px-Jean_Kirschtein.png'],
    ['Sasha Braus','https://upload.wikimedia.org/wikipedia/en/thumb/6/6f/Sasha_Braus.png/220px-Sasha_Braus.png'],
    ['Connie Springer','https://upload.wikimedia.org/wikipedia/en/thumb/2/28/Connie_Springer.png/220px-Connie_Springer.png'],
    ['Ymir','https://upload.wikimedia.org/wikipedia/en/thumb/d/d8/Ymir_%28AoT%29.png/220px-Ymir_%28AoT%29.png'],
    ['Pieck Finger','https://upload.wikimedia.org/wikipedia/en/thumb/7/7c/Pieck_Finger.png/220px-Pieck_Finger.png'],
  ]); console.log('✅ Attack on Titan');

  // ── DEATH NOTE ──────────────────────────────────────────────────────
  total += await add('Anime','Death Note',[
    ['Light Yagami','https://upload.wikimedia.org/wikipedia/en/thumb/6/60/Light_Yagami_character_image.png/220px-Light_Yagami_character_image.png'],
    ['L Lawliet','https://upload.wikimedia.org/wikipedia/en/thumb/4/4f/L_Lawliet_DN.png/220px-L_Lawliet_DN.png'],
    ['Misa Amane','https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Misa_Amane.png/220px-Misa_Amane.png'],
    ['Ryuk','https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Ryuk_Shinigami_Death_Note.png/220px-Ryuk_Shinigami_Death_Note.png'],
    ['Near','https://upload.wikimedia.org/wikipedia/en/thumb/3/33/Near_Death_Note.png/220px-Near_Death_Note.png'],
    ['Mello','https://upload.wikimedia.org/wikipedia/en/thumb/3/31/Mello_Death_Note.png/220px-Mello_Death_Note.png'],
    ['Rem','https://upload.wikimedia.org/wikipedia/en/thumb/c/ce/Rem_Death_Note.png/220px-Rem_Death_Note.png'],
    ['Teru Mikami','https://upload.wikimedia.org/wikipedia/en/thumb/0/09/Teru_Mikami.png/220px-Teru_Mikami.png'],
    ['Watari','https://upload.wikimedia.org/wikipedia/en/thumb/1/10/Watari_Death_Note.png/220px-Watari_Death_Note.png'],
    ['Kiyomi Takada','https://upload.wikimedia.org/wikipedia/en/thumb/c/c7/Kiyomi_Takada.png/220px-Kiyomi_Takada.png'],
  ]); console.log('✅ Death Note');

  // ── FULLMETAL ALCHEMIST ─────────────────────────────────────────────
  total += await add('Anime','Fullmetal Alchemist',[
    ['Edward Elric','https://upload.wikimedia.org/wikipedia/en/thumb/6/63/Edward_Elric_Fullmetal_Alchemist.png/220px-Edward_Elric_Fullmetal_Alchemist.png'],
    ['Alphonse Elric','https://upload.wikimedia.org/wikipedia/en/thumb/6/67/Alphonse_Elric_Fullmetal_Alchemist.png/220px-Alphonse_Elric_Fullmetal_Alchemist.png'],
    ['Roy Mustang','https://upload.wikimedia.org/wikipedia/en/thumb/5/52/Roy_Mustang_FMA.png/220px-Roy_Mustang_FMA.png'],
    ['Winry Rockbell','https://upload.wikimedia.org/wikipedia/en/thumb/a/aa/Winry_Rockbell_FMA.png/220px-Winry_Rockbell_FMA.png'],
    ['Riza Hawkeye','https://upload.wikimedia.org/wikipedia/en/thumb/6/61/Riza_Hawkeye_FMA.png/220px-Riza_Hawkeye_FMA.png'],
    ['Scar','https://upload.wikimedia.org/wikipedia/en/thumb/c/cb/Scar_FMA.png/220px-Scar_FMA.png'],
    ['Father','https://upload.wikimedia.org/wikipedia/en/thumb/5/51/Father_FMA_Brotherhood.png/220px-Father_FMA_Brotherhood.png'],
    ['Greed','https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Greed_FMA.png/220px-Greed_FMA.png'],
    ['Envy','https://upload.wikimedia.org/wikipedia/en/thumb/7/7a/Envy_FMA.png/220px-Envy_FMA.png'],
    ['Lust','https://upload.wikimedia.org/wikipedia/en/thumb/7/72/Lust_FMA.png/220px-Lust_FMA.png'],
    ['Maes Hughes','https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Maes_Hughes_FMA.png/220px-Maes_Hughes_FMA.png'],
    ['Van Hohenheim','https://upload.wikimedia.org/wikipedia/en/thumb/c/cf/Van_Hohenheim_FMA.png/220px-Van_Hohenheim_FMA.png'],
  ]); console.log('✅ FMA');

  // ── HXH ─────────────────────────────────────────────────────────────
  total += await add('Anime','Hunter x Hunter',[
    ['Gon Freecss','https://upload.wikimedia.org/wikipedia/en/thumb/0/04/Gon_Freecss.png/220px-Gon_Freecss.png'],
    ['Killua Zoldyck','https://upload.wikimedia.org/wikipedia/en/thumb/a/a8/Killua_Zoldyck.png/220px-Killua_Zoldyck.png'],
    ['Kurapika','https://upload.wikimedia.org/wikipedia/en/thumb/3/3c/Kurapika_HxH.png/220px-Kurapika_HxH.png'],
    ['Leorio','https://upload.wikimedia.org/wikipedia/en/thumb/6/62/Leorio_Paladiknight.png/220px-Leorio_Paladiknight.png'],
    ['Hisoka','https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Hisoka_HxH.png/220px-Hisoka_HxH.png'],
    ['Chrollo Lucilfer','https://upload.wikimedia.org/wikipedia/en/thumb/3/3e/Chrollo_Lucilfer.png/220px-Chrollo_Lucilfer.png'],
    ['Meruem','https://upload.wikimedia.org/wikipedia/en/thumb/0/0d/Meruem_HxH.png/220px-Meruem_HxH.png'],
    ['Neferpitou','https://upload.wikimedia.org/wikipedia/en/thumb/3/36/Neferpitou_HxH.png/220px-Neferpitou_HxH.png'],
    ['Netero','https://upload.wikimedia.org/wikipedia/en/thumb/3/34/Netero_HxH.png/220px-Netero_HxH.png'],
    ['Illumi Zoldyck','https://upload.wikimedia.org/wikipedia/en/thumb/b/ba/Illumi_Zoldyck.png/220px-Illumi_Zoldyck.png'],
    ['Biscuit Krueger','https://upload.wikimedia.org/wikipedia/en/thumb/2/27/Bisky_HxH.png/220px-Bisky_HxH.png'],
  ]); console.log('✅ HxH');

  // ── SAO ──────────────────────────────────────────────────────────────
  total += await add('Anime','Sword Art Online',[
    ['Kirito','https://upload.wikimedia.org/wikipedia/en/thumb/d/d4/Kirito_SAO.png/220px-Kirito_SAO.png'],
    ['Asuna','https://upload.wikimedia.org/wikipedia/en/thumb/6/64/Asuna_SAO.png/220px-Asuna_SAO.png'],
    ['Sinon','https://upload.wikimedia.org/wikipedia/en/thumb/1/15/Sinon_SAO.png/220px-Sinon_SAO.png'],
    ['Alice','https://upload.wikimedia.org/wikipedia/en/thumb/5/52/Alice_SAO.png/220px-Alice_SAO.png'],
    ['Eugeo','https://upload.wikimedia.org/wikipedia/en/thumb/9/94/Eugeo_SAO.png/220px-Eugeo_SAO.png'],
    ['Leafa','https://upload.wikimedia.org/wikipedia/en/thumb/3/34/Leafa_SAO.png/220px-Leafa_SAO.png'],
    ['Yui','https://upload.wikimedia.org/wikipedia/en/thumb/6/67/Yui_SAO.png/220px-Yui_SAO.png'],
    ['Klein','https://upload.wikimedia.org/wikipedia/en/thumb/7/75/Klein_SAO.png/220px-Klein_SAO.png'],
    ['Agil','https://upload.wikimedia.org/wikipedia/en/thumb/a/ac/Agil_SAO.png/220px-Agil_SAO.png'],
    ['Bercouli','https://upload.wikimedia.org/wikipedia/en/thumb/1/1a/Bercouli_SAO.png/220px-Bercouli_SAO.png'],
  ]); console.log('✅ SAO');

  // ── MHA ──────────────────────────────────────────────────────────────
  total += await add('Anime','My Hero Academia',[
    ['Izuku Midoriya','https://upload.wikimedia.org/wikipedia/en/thumb/0/0e/Izuku_Midoriya_MHA.png/220px-Izuku_Midoriya_MHA.png'],
    ['Katsuki Bakugo','https://upload.wikimedia.org/wikipedia/en/thumb/0/0b/Katsuki_Bakugo_MHA.png/220px-Katsuki_Bakugo_MHA.png'],
    ['All Might','https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/All_Might_MHA.png/220px-All_Might_MHA.png'],
    ['Shoto Todoroki','https://upload.wikimedia.org/wikipedia/en/thumb/f/f3/Shoto_Todoroki_MHA.png/220px-Shoto_Todoroki_MHA.png'],
    ['Ochaco Uraraka','https://upload.wikimedia.org/wikipedia/en/thumb/c/cc/Ochako_Uraraka_MHA.png/220px-Ochako_Uraraka_MHA.png'],
    ['Eraserhead','https://upload.wikimedia.org/wikipedia/en/thumb/1/19/Shota_Aizawa_MHA.png/220px-Shota_Aizawa_MHA.png'],
    ['Endeavor','https://upload.wikimedia.org/wikipedia/en/thumb/3/31/Enji_Todoroki_MHA.png/220px-Enji_Todoroki_MHA.png'],
    ['Hawks','https://upload.wikimedia.org/wikipedia/en/thumb/0/08/Keigo_Takami_MHA.png/220px-Keigo_Takami_MHA.png'],
    ['Tomura Shigaraki','https://upload.wikimedia.org/wikipedia/en/thumb/0/0f/Tomura_Shigaraki_MHA.png/220px-Tomura_Shigaraki_MHA.png'],
    ['Dabi','https://upload.wikimedia.org/wikipedia/en/thumb/5/53/Dabi_MHA.png/220px-Dabi_MHA.png'],
    ['Toga Himiko','https://upload.wikimedia.org/wikipedia/en/thumb/6/67/Himiko_Toga_MHA.png/220px-Himiko_Toga_MHA.png'],
    ['Mirio Togata','https://upload.wikimedia.org/wikipedia/en/thumb/1/1e/Mirio_Togata_MHA.png/220px-Mirio_Togata_MHA.png'],
    ['Tenya Iida','https://upload.wikimedia.org/wikipedia/en/thumb/7/73/Tenya_Iida_MHA.png/220px-Tenya_Iida_MHA.png'],
    ['Best Jeanist','https://upload.wikimedia.org/wikipedia/en/thumb/c/c8/Best_Jeanist_MHA.png/220px-Best_Jeanist_MHA.png'],
  ]); console.log('✅ MHA');

  // ── FAIRY TAIL ───────────────────────────────────────────────────────
  total += await add('Anime','Fairy Tail',[
    ['Natsu Dragneel','https://upload.wikimedia.org/wikipedia/en/thumb/7/74/Natsu_Dragneel.png/220px-Natsu_Dragneel.png'],
    ['Lucy Heartfilia','https://upload.wikimedia.org/wikipedia/en/thumb/7/79/Lucy_Heartfilia.png/220px-Lucy_Heartfilia.png'],
    ['Erza Scarlet','https://upload.wikimedia.org/wikipedia/en/thumb/e/e6/Erza_Scarlet.png/220px-Erza_Scarlet.png'],
    ['Gray Fullbuster','https://upload.wikimedia.org/wikipedia/en/thumb/4/4f/Gray_Fullbuster.png/220px-Gray_Fullbuster.png'],
    ['Happy','https://upload.wikimedia.org/wikipedia/en/thumb/0/05/Happy_FairyTail.png/220px-Happy_FairyTail.png'],
    ['Wendy Marvell','https://upload.wikimedia.org/wikipedia/en/thumb/c/c8/Wendy_Marvell.png/220px-Wendy_Marvell.png'],
    ['Laxus Dreyar','https://upload.wikimedia.org/wikipedia/en/thumb/5/5b/Laxus_Dreyar.png/220px-Laxus_Dreyar.png'],
    ['Jellal Fernandes','https://upload.wikimedia.org/wikipedia/en/thumb/1/1f/Jellal_Fernandes.png/220px-Jellal_Fernandes.png'],
    ['Zeref','https://upload.wikimedia.org/wikipedia/en/thumb/c/c8/Zeref_FairyTail.png/220px-Zeref_FairyTail.png'],
    ['Acnologia','https://upload.wikimedia.org/wikipedia/en/thumb/f/f0/Acnologia_FairyTail.png/220px-Acnologia_FairyTail.png'],
    ['Gildarts Clive','https://upload.wikimedia.org/wikipedia/en/thumb/9/9f/Gildarts_Clive.png/220px-Gildarts_Clive.png'],
    ['Makarov Dreyar','https://upload.wikimedia.org/wikipedia/en/thumb/b/b0/Makarov_Dreyar.png/220px-Makarov_Dreyar.png'],
    ['Mirajane Strauss','https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/Mirajane_Strauss.png/220px-Mirajane_Strauss.png'],
  ]); console.log('✅ Fairy Tail');

  // ── BLEACH ───────────────────────────────────────────────────────────
  total += await add('Anime','Bleach',[
    ['Ichigo Kurosaki','https://upload.wikimedia.org/wikipedia/en/thumb/f/f2/Ichigo_Kurosaki_character.png/220px-Ichigo_Kurosaki_character.png'],
    ['Rukia Kuchiki','https://upload.wikimedia.org/wikipedia/en/thumb/9/94/Rukia_Kuchiki.png/220px-Rukia_Kuchiki.png'],
    ['Orihime Inoue','https://upload.wikimedia.org/wikipedia/en/thumb/7/78/Orihime_Inoue.png/220px-Orihime_Inoue.png'],
    ['Byakuya Kuchiki','https://upload.wikimedia.org/wikipedia/en/thumb/7/7e/Byakuya_Kuchiki.png/220px-Byakuya_Kuchiki.png'],
    ['Toshiro Hitsugaya','https://upload.wikimedia.org/wikipedia/en/thumb/7/7e/T%C5%8Dshir%C5%8D_Hitsugaya.png/220px-T%C5%8Dshir%C5%8D_Hitsugaya.png'],
    ['Sosuke Aizen','https://upload.wikimedia.org/wikipedia/en/thumb/3/39/Sosuke_Aizen_character.png/220px-Sosuke_Aizen_character.png'],
    ['Kisuke Urahara','https://upload.wikimedia.org/wikipedia/en/thumb/0/04/Kisuke_Urahara.png/220px-Kisuke_Urahara.png'],
    ['Grimmjow Jaegerjaquez','https://upload.wikimedia.org/wikipedia/en/thumb/0/0c/Grimmjow_Jaegerjaquez.png/220px-Grimmjow_Jaegerjaquez.png'],
    ['Ulquiorra Cifer','https://upload.wikimedia.org/wikipedia/en/thumb/3/38/Ulquiorra_Cifer.png/220px-Ulquiorra_Cifer.png'],
    ['Kenpachi Zaraki','https://upload.wikimedia.org/wikipedia/en/thumb/6/69/Kenpachi_Zaraki.png/220px-Kenpachi_Zaraki.png'],
    ['Renji Abarai','https://upload.wikimedia.org/wikipedia/en/thumb/3/38/Renji_Abarai.png/220px-Renji_Abarai.png'],
    ['Yhwach','https://upload.wikimedia.org/wikipedia/en/thumb/5/5e/Yhwach_Bleach.png/220px-Yhwach_Bleach.png'],
    ['Rangiku Matsumoto','https://upload.wikimedia.org/wikipedia/en/thumb/8/8e/Rangiku_Matsumoto.png/220px-Rangiku_Matsumoto.png'],
  ]); console.log('✅ Bleach');

  // ── TOKYO GHOUL ──────────────────────────────────────────────────────
  total += await add('Anime','Tokyo Ghoul',[
    ['Ken Kaneki','https://upload.wikimedia.org/wikipedia/en/thumb/a/a3/Ken_Kaneki_Tokyo_Ghoul.png/220px-Ken_Kaneki_Tokyo_Ghoul.png'],
    ['Touka Kirishima','https://upload.wikimedia.org/wikipedia/en/thumb/e/e8/Touka_Kirishima.png/220px-Touka_Kirishima.png'],
    ['Rize Kamishiro','https://upload.wikimedia.org/wikipedia/en/thumb/9/97/Rize_Kamishiro.png/220px-Rize_Kamishiro.png'],
    ['Juuzou Suzuya','https://upload.wikimedia.org/wikipedia/en/thumb/a/a9/Juuzou_Suzuya.png/220px-Juuzou_Suzuya.png'],
    ['Kishou Arima','https://upload.wikimedia.org/wikipedia/en/thumb/8/88/Kishou_Arima.png/220px-Kishou_Arima.png'],
    ['Uta','https://upload.wikimedia.org/wikipedia/en/thumb/6/69/Uta_Tokyo_Ghoul.png/220px-Uta_Tokyo_Ghoul.png'],
    ['Shuu Tsukiyama','https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Shuu_Tsukiyama.png/220px-Shuu_Tsukiyama.png'],
    ['Hide Nagachika','https://upload.wikimedia.org/wikipedia/en/thumb/6/61/Hideyoshi_Nagachika.png/220px-Hideyoshi_Nagachika.png'],
    ['Yoshimura','https://upload.wikimedia.org/wikipedia/en/thumb/a/ac/Kuzen_Yoshimura.png/220px-Kuzen_Yoshimura.png'],
    ['Naki','https://upload.wikimedia.org/wikipedia/en/thumb/2/27/Naki_Tokyo_Ghoul.png/220px-Naki_Tokyo_Ghoul.png'],
  ]); console.log('✅ Tokyo Ghoul');

  // ── JUJUTSU KAISEN ───────────────────────────────────────────────────
  total += await add('Anime','Jujutsu Kaisen',[
    ['Yuji Itadori','https://upload.wikimedia.org/wikipedia/en/thumb/5/55/Yuji_Itadori.png/220px-Yuji_Itadori.png'],
    ['Megumi Fushiguro','https://upload.wikimedia.org/wikipedia/en/thumb/0/0a/Megumi_Fushiguro.png/220px-Megumi_Fushiguro.png'],
    ['Nobara Kugisaki','https://upload.wikimedia.org/wikipedia/en/thumb/5/58/Nobara_Kugisaki.png/220px-Nobara_Kugisaki.png'],
    ['Satoru Gojo','https://upload.wikimedia.org/wikipedia/en/thumb/a/ac/Satoru_Gojo.png/220px-Satoru_Gojo.png'],
    ['Suguru Geto','https://upload.wikimedia.org/wikipedia/en/thumb/d/d3/Suguru_Geto.png/220px-Suguru_Geto.png'],
    ['Ryomen Sukuna','https://upload.wikimedia.org/wikipedia/en/thumb/1/1c/Ryomen_Sukuna.png/220px-Ryomen_Sukuna.png'],
    ['Nanami Kento','https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Kento_Nanami.png/220px-Kento_Nanami.png'],
    ['Aoi Todo','https://upload.wikimedia.org/wikipedia/en/thumb/1/11/Aoi_Todo_JJK.png/220px-Aoi_Todo_JJK.png'],
    ['Maki Zenin','https://upload.wikimedia.org/wikipedia/en/thumb/5/5c/Maki_Zenin.png/220px-Maki_Zenin.png'],
    ['Toji Fushiguro','https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Toji_Fushiguro.png/220px-Toji_Fushiguro.png'],
    ['Yuta Okkotsu','https://upload.wikimedia.org/wikipedia/en/thumb/e/e6/Yuta_Okkotsu.png/220px-Yuta_Okkotsu.png'],
    ['Toge Inumaki','https://upload.wikimedia.org/wikipedia/en/thumb/0/00/Toge_Inumaki.png/220px-Toge_Inumaki.png'],
    ['Panda','https://upload.wikimedia.org/wikipedia/en/thumb/c/c4/Panda_JJK.png/220px-Panda_JJK.png'],
  ]); console.log('✅ JJK');

  // ── VINLAND SAGA ─────────────────────────────────────────────────────
  total += await add('Anime','Vinland Saga',[
    ['Thorfinn','https://upload.wikimedia.org/wikipedia/en/thumb/5/51/Thorfinn_Vinland_Saga.png/220px-Thorfinn_Vinland_Saga.png'],
    ['Askeladd','https://upload.wikimedia.org/wikipedia/en/thumb/3/30/Askeladd_Vinland_Saga.png/220px-Askeladd_Vinland_Saga.png'],
    ['Thorkell','https://upload.wikimedia.org/wikipedia/en/thumb/5/5e/Thorkell_Vinland_Saga.png/220px-Thorkell_Vinland_Saga.png'],
    ['Canute','https://upload.wikimedia.org/wikipedia/en/thumb/e/e2/Canute_Vinland_Saga.png/220px-Canute_Vinland_Saga.png'],
    ['Einar','https://upload.wikimedia.org/wikipedia/en/thumb/6/6b/Einar_Vinland_Saga.png/220px-Einar_Vinland_Saga.png'],
    ['Thors','https://upload.wikimedia.org/wikipedia/en/thumb/6/61/Thors_Vinland_Saga.png/220px-Thors_Vinland_Saga.png'],
    ['Snake','https://upload.wikimedia.org/wikipedia/en/thumb/6/63/Snake_Vinland_Saga.png/220px-Snake_Vinland_Saga.png'],
    ['Leif Erikson','https://upload.wikimedia.org/wikipedia/en/thumb/4/47/Leif_Erikson_Vinland_Saga.png/220px-Leif_Erikson_Vinland_Saga.png'],
    ['Floki','https://upload.wikimedia.org/wikipedia/en/thumb/3/30/Floki_Vinland_Saga.png/220px-Floki_Vinland_Saga.png'],
    ['Gudrid','https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Gudrid_Vinland_Saga.png/220px-Gudrid_Vinland_Saga.png'],
  ]); console.log('✅ Vinland Saga');

  // ── AVATAR ───────────────────────────────────────────────────────────
  total += await add('Anime','Avatar: The Last Airbender',[
    ['Aang','https://upload.wikimedia.org/wikipedia/en/thumb/3/3e/Aang_-_Avatar.png/220px-Aang_-_Avatar.png'],
    ['Katara','https://upload.wikimedia.org/wikipedia/en/thumb/8/8b/Katara_-_Avatar.png/220px-Katara_-_Avatar.png'],
    ['Sokka','https://upload.wikimedia.org/wikipedia/en/thumb/a/a5/Sokka_Avatar.png/220px-Sokka_Avatar.png'],
    ['Toph Beifong','https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Toph_Beifong.png/220px-Toph_Beifong.png'],
    ['Zuko','https://upload.wikimedia.org/wikipedia/en/thumb/0/0b/Zuko_-_Avatar.png/220px-Zuko_-_Avatar.png'],
    ['Azula','https://upload.wikimedia.org/wikipedia/en/thumb/c/c7/Azula_Avatar.png/220px-Azula_Avatar.png'],
    ['Iroh','https://upload.wikimedia.org/wikipedia/en/thumb/5/55/Iroh_Avatar.png/220px-Iroh_Avatar.png'],
    ['Ozai','https://upload.wikimedia.org/wikipedia/en/thumb/e/e1/Ozai_Avatar.png/220px-Ozai_Avatar.png'],
    ['Ty Lee','https://upload.wikimedia.org/wikipedia/en/thumb/5/59/Ty_Lee_Avatar.png/220px-Ty_Lee_Avatar.png'],
    ['Mai','https://upload.wikimedia.org/wikipedia/en/thumb/3/35/Mai_Avatar.png/220px-Mai_Avatar.png'],
    ['Suki','https://upload.wikimedia.org/wikipedia/en/thumb/3/35/Suki_Avatar.png/220px-Suki_Avatar.png'],
    ['Yue','https://upload.wikimedia.org/wikipedia/en/thumb/f/f4/Yue_Avatar.png/220px-Yue_Avatar.png'],
    ['Jet','https://upload.wikimedia.org/wikipedia/en/thumb/7/77/Jet_Avatar.png/220px-Jet_Avatar.png'],
    ['König Bumi','https://upload.wikimedia.org/wikipedia/en/thumb/5/5b/Bumi_Avatar.png/220px-Bumi_Avatar.png'],
  ]); console.log('✅ Avatar');

  // ── CHAINSAW MAN ─────────────────────────────────────────────────────
  total += await add('Anime','Chainsaw Man',[
    ['Denji','https://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Denji_Chainsaw_Man.png/220px-Denji_Chainsaw_Man.png'],
    ['Power','https://upload.wikimedia.org/wikipedia/en/thumb/1/17/Power_Chainsaw_Man.png/220px-Power_Chainsaw_Man.png'],
    ['Aki Hayakawa','https://upload.wikimedia.org/wikipedia/en/thumb/6/64/Aki_Hayakawa.png/220px-Aki_Hayakawa.png'],
    ['Makima','https://upload.wikimedia.org/wikipedia/en/thumb/3/3a/Makima_Chainsaw_Man.png/220px-Makima_Chainsaw_Man.png'],
    ['Reze','https://upload.wikimedia.org/wikipedia/en/thumb/f/f1/Reze_Chainsaw_Man.png/220px-Reze_Chainsaw_Man.png'],
    ['Kobeni Higashiyama','https://upload.wikimedia.org/wikipedia/en/thumb/e/ef/Kobeni_Higashiyama.png/220px-Kobeni_Higashiyama.png'],
    ['Himeno','https://upload.wikimedia.org/wikipedia/en/thumb/2/2e/Himeno_Chainsaw_Man.png/220px-Himeno_Chainsaw_Man.png'],
    ['Quanxi','https://upload.wikimedia.org/wikipedia/en/thumb/6/62/Quanxi_Chainsaw_Man.png/220px-Quanxi_Chainsaw_Man.png'],
    ['Kishibe','https://upload.wikimedia.org/wikipedia/en/thumb/5/5e/Kishibe_Chainsaw_Man.png/220px-Kishibe_Chainsaw_Man.png'],
  ]); console.log('✅ Chainsaw Man');

  // ── SPY x FAMILY ─────────────────────────────────────────────────────
  total += await add('Anime','Spy x Family',[
    ['Loid Forger','https://upload.wikimedia.org/wikipedia/en/thumb/e/e8/Loid_Forger.png/220px-Loid_Forger.png'],
    ['Yor Forger','https://upload.wikimedia.org/wikipedia/en/thumb/3/36/Yor_Forger.png/220px-Yor_Forger.png'],
    ['Anya Forger','https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Anya_Forger.png/220px-Anya_Forger.png'],
    ['Yuri Briar','https://upload.wikimedia.org/wikipedia/en/thumb/7/72/Yuri_Briar.png/220px-Yuri_Briar.png'],
    ['Damian Desmond','https://upload.wikimedia.org/wikipedia/en/thumb/2/2c/Damian_Desmond.png/220px-Damian_Desmond.png'],
    ['Becky Blackbell','https://upload.wikimedia.org/wikipedia/en/thumb/6/60/Becky_Blackbell.png/220px-Becky_Blackbell.png'],
    ['Bond Forger','https://upload.wikimedia.org/wikipedia/en/thumb/9/9b/Bond_Forger.png/220px-Bond_Forger.png'],
    ['Franky Franklin','https://upload.wikimedia.org/wikipedia/en/thumb/a/a2/Franky_Franklin.png/220px-Franky_Franklin.png'],
  ]); console.log('✅ Spy x Family');

  // ── MOB PSYCHO ───────────────────────────────────────────────────────
  total += await add('Anime','Mob Psycho 100',[
    ['Mob (Shigeo Kageyama)','https://upload.wikimedia.org/wikipedia/en/thumb/8/8d/Shigeo_Kageyama.png/220px-Shigeo_Kageyama.png'],
    ['Reigen Arataka','https://upload.wikimedia.org/wikipedia/en/thumb/3/34/Arataka_Reigen.png/220px-Arataka_Reigen.png'],
    ['Dimple','https://upload.wikimedia.org/wikipedia/en/thumb/3/37/Dimple_Mob_Psycho.png/220px-Dimple_Mob_Psycho.png'],
    ['Ritsu Kageyama','https://upload.wikimedia.org/wikipedia/en/thumb/6/6b/Ritsu_Kageyama.png/220px-Ritsu_Kageyama.png'],
    ['Teruki Hanazawa','https://upload.wikimedia.org/wikipedia/en/thumb/7/77/Teruki_Hanazawa.png/220px-Teruki_Hanazawa.png'],
    ['Sho Suzuki','https://upload.wikimedia.org/wikipedia/en/thumb/2/23/Sho_Suzuki.png/220px-Sho_Suzuki.png'],
    ['Toichiro Suzuki','https://upload.wikimedia.org/wikipedia/en/thumb/1/14/Toichiro_Suzuki.png/220px-Toichiro_Suzuki.png'],
  ]); console.log('✅ Mob Psycho');

  // ── VIOLET EVERGARDEN ────────────────────────────────────────────────
  total += await add('Anime','Violet Evergarden',[
    ['Violet Evergarden','https://upload.wikimedia.org/wikipedia/en/thumb/a/af/Violet_Evergarden_character.png/220px-Violet_Evergarden_character.png'],
    ['Gilbert Bougainvillea','https://upload.wikimedia.org/wikipedia/en/thumb/1/13/Gilbert_Bougainvillea.png/220px-Gilbert_Bougainvillea.png'],
    ['Claudia Hodgins','https://upload.wikimedia.org/wikipedia/en/thumb/1/1d/Claudia_Hodgins.png/220px-Claudia_Hodgins.png'],
    ['Cattleya Baudelaire','https://upload.wikimedia.org/wikipedia/en/thumb/c/c8/Cattleya_Baudelaire.png/220px-Cattleya_Baudelaire.png'],
    ['Benedict Blue','https://upload.wikimedia.org/wikipedia/en/thumb/5/57/Benedict_Blue.png/220px-Benedict_Blue.png'],
    ['Iris Cannary','https://upload.wikimedia.org/wikipedia/en/thumb/4/4d/Iris_Cannary.png/220px-Iris_Cannary.png'],
    ['Dietfried Bougainvillea','https://upload.wikimedia.org/wikipedia/en/thumb/d/d5/Dietfried_Bougainvillea.png/220px-Dietfried_Bougainvillea.png'],
  ]); console.log('✅ Violet Evergarden');

  // ═══════════════════════════════════════════════════════════
  // ONE PIECE — Wikipedia Charakter-Bilder
  // ═══════════════════════════════════════════════════════════
  const opChars = [
    ['Ruffy','https://upload.wikimedia.org/wikipedia/en/thumb/9/90/Monkey_D_Luffy.png/220px-Monkey_D_Luffy.png'],
    ['Zoro','https://upload.wikimedia.org/wikipedia/en/thumb/3/38/Roronoa_Zoro.png/220px-Roronoa_Zoro.png'],
    ['Nami','https://upload.wikimedia.org/wikipedia/en/thumb/4/4a/Nami_One_Piece.png/220px-Nami_One_Piece.png'],
    ['Lysop','https://upload.wikimedia.org/wikipedia/en/thumb/0/05/Usopp_One_Piece.png/220px-Usopp_One_Piece.png'],
    ['Sanji','https://upload.wikimedia.org/wikipedia/en/thumb/8/8b/Sanji_One_Piece.png/220px-Sanji_One_Piece.png'],
    ['Chopper','https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Tony_Tony_Chopper.png/220px-Tony_Tony_Chopper.png'],
    ['Robin','https://upload.wikimedia.org/wikipedia/en/thumb/e/ee/Nico_Robin.png/220px-Nico_Robin.png'],
    ['Franky','https://upload.wikimedia.org/wikipedia/en/thumb/2/2b/Franky_One_Piece.png/220px-Franky_One_Piece.png'],
    ['Brook','https://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Brook_One_Piece.png/220px-Brook_One_Piece.png'],
    ['Jinbe','https://upload.wikimedia.org/wikipedia/en/thumb/6/6b/Jinbe_One_Piece.png/220px-Jinbe_One_Piece.png'],
    ['Shanks','https://upload.wikimedia.org/wikipedia/en/thumb/3/34/Shanks_One_Piece.png/220px-Shanks_One_Piece.png'],
    ['Ace','https://upload.wikimedia.org/wikipedia/en/thumb/9/91/Portgas_D_Ace.png/220px-Portgas_D_Ace.png'],
    ['Whitebeard','https://upload.wikimedia.org/wikipedia/en/thumb/e/e7/Edward_Newgate.png/220px-Edward_Newgate.png'],
    ['Big Mom','https://upload.wikimedia.org/wikipedia/en/thumb/e/e8/Charlotte_Linlin.png/220px-Charlotte_Linlin.png'],
    ['Kaido','https://upload.wikimedia.org/wikipedia/en/thumb/d/d6/Kaido_One_Piece.png/220px-Kaido_One_Piece.png'],
    ['Blackbeard','https://upload.wikimedia.org/wikipedia/en/thumb/2/27/Marshall_D_Teach.png/220px-Marshall_D_Teach.png'],
    ['Mihawk','https://upload.wikimedia.org/wikipedia/en/thumb/0/09/Dracule_Mihawk.png/220px-Dracule_Mihawk.png'],
    ['Hancock','https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Boa_Hancock.png/220px-Boa_Hancock.png'],
    ['Law','https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Trafalgar_Law.png/220px-Trafalgar_Law.png'],
    ['Dragon','https://upload.wikimedia.org/wikipedia/en/thumb/5/53/Monkey_D_Dragon.png/220px-Monkey_D_Dragon.png'],
    ['Sabo','https://upload.wikimedia.org/wikipedia/en/thumb/7/76/Sabo_One_Piece.png/220px-Sabo_One_Piece.png'],
    ['Garp','https://upload.wikimedia.org/wikipedia/en/thumb/c/ca/Monkey_D_Garp.png/220px-Monkey_D_Garp.png'],
    ['Akainu','https://upload.wikimedia.org/wikipedia/en/thumb/4/4d/Sakazuki_One_Piece.png/220px-Sakazuki_One_Piece.png'],
    ['Aokiji','https://upload.wikimedia.org/wikipedia/en/thumb/d/d7/Kuzan_One_Piece.png/220px-Kuzan_One_Piece.png'],
    ['Kizaru','https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Borsalino_One_Piece.png/220px-Borsalino_One_Piece.png'],
    ['Fujitora','https://upload.wikimedia.org/wikipedia/en/thumb/3/3a/Issho_One_Piece.png/220px-Issho_One_Piece.png'],
    ['Yamato','https://upload.wikimedia.org/wikipedia/en/thumb/2/22/Yamato_One_Piece.png/220px-Yamato_One_Piece.png'],
    ['Reiju','https://upload.wikimedia.org/wikipedia/en/thumb/7/74/Vinsmoke_Reiju.png/220px-Vinsmoke_Reiju.png'],
    ['Perona','https://upload.wikimedia.org/wikipedia/en/thumb/3/39/Perona_One_Piece.png/220px-Perona_One_Piece.png'],
    ['Kid','https://upload.wikimedia.org/wikipedia/en/thumb/4/4a/Eustass_Kid.png/220px-Eustass_Kid.png'],
  ];

  total += await add('One Piece','Strohhutbande', opChars.slice(0,10));
  total += await add('One Piece','Marine',[opChars[22],opChars[23],opChars[24],opChars[25],opChars[21],
    ['Sengoku','https://upload.wikimedia.org/wikipedia/en/thumb/2/2e/Sengoku_One_Piece.png/220px-Sengoku_One_Piece.png'],
    ['Smoker','https://upload.wikimedia.org/wikipedia/en/thumb/c/cd/Smoker_One_Piece.png/220px-Smoker_One_Piece.png'],
    ['Tashigi','https://upload.wikimedia.org/wikipedia/en/thumb/0/07/Tashigi_One_Piece.png/220px-Tashigi_One_Piece.png'],
    ['Koby','https://upload.wikimedia.org/wikipedia/en/thumb/4/44/Koby_One_Piece.png/220px-Koby_One_Piece.png'],
  ]);
  total += await add('One Piece','Piraten',[opChars[12],opChars[10],opChars[13],opChars[14],opChars[15],opChars[11],opChars[18],opChars[29],opChars[16],opChars[17],opChars[28],opChars[27]]);
  total += await add('One Piece','Revolutionäre',[opChars[19],opChars[20],
    ['Ivankov','https://upload.wikimedia.org/wikipedia/en/thumb/f/f3/Emporio_Ivankov.png/220px-Emporio_Ivankov.png'],
    ['Koala','https://upload.wikimedia.org/wikipedia/en/thumb/4/4a/Koala_One_Piece.png/220px-Koala_One_Piece.png'],
    ['Belo Betty','https://upload.wikimedia.org/wikipedia/en/thumb/7/78/Belo_Betty.png/220px-Belo_Betty.png'],
  ]);
  total += await add('One Piece','Alle Kaiser',[opChars[12],opChars[10],opChars[13],opChars[14],opChars[15],opChars[0]]);
  total += await add('One Piece','Schwertkämpfer',[opChars[1],opChars[16],opChars[10],opChars[18],
    ['Kinemon','https://upload.wikimedia.org/wikipedia/en/thumb/f/f6/Kinemon_One_Piece.png/220px-Kinemon_One_Piece.png'],
  ]);
  total += await add('One Piece','Teufelsfrucht-Nutzer',[opChars[0],opChars[11],opChars[15],opChars[22],opChars[23],opChars[24],opChars[7],opChars[13],opChars[14],opChars[18]]);
  total += await add('One Piece','Frauen',[opChars[2],opChars[7],opChars[17],opChars[13],opChars[27],opChars[28],opChars[26],
    ['Tashigi','https://upload.wikimedia.org/wikipedia/en/thumb/0/07/Tashigi_One_Piece.png/220px-Tashigi_One_Piece.png'],
    ['Koala','https://upload.wikimedia.org/wikipedia/en/thumb/4/4a/Koala_One_Piece.png/220px-Koala_One_Piece.png'],
  ]);
  total += await add('One Piece','Alle Charaktere', opChars);
  total += await add('One Piece','Pre Timeskip', opChars.slice(0,9));
  total += await add('One Piece','Post Timeskip', opChars.slice(0,10));
  total += await add('One Piece','Outfits der Strohhüte', opChars.slice(0,10).map(([name, url]) => [name + ' (Outfit)', url]));
  total += await add('One Piece','Arcs',[
    ['East Blue Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Alabasta Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Skypiea Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Water 7 Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Enies Lobby Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Thriller Bark Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Marineford Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Fishman Island Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Punk Hazard Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Dressrosa Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Whole Cake Island Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Wano Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Egghead Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Reverie Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
    ['Sabaody Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/6/73245.jpg&w=200&h=280&fit=cover'],
  ]);
  console.log('✅ One Piece');

  // ═══════════════════════════════════════════════════════════
  // NARUTO — Wikipedia Charakter-Bilder
  // ═══════════════════════════════════════════════════════════
  const naChars = [
    ['Naruto','https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/NarutoUzumaki.png/220px-NarutoUzumaki.png'],
    ['Sasuke','https://upload.wikimedia.org/wikipedia/en/thumb/3/31/SasukeUchiha.png/220px-SasukeUchiha.png'],
    ['Sakura','https://upload.wikimedia.org/wikipedia/en/thumb/2/2e/SakuraHaruno.png/220px-SakuraHaruno.png'],
    ['Kakashi','https://upload.wikimedia.org/wikipedia/en/thumb/2/27/Kakashi_Hatake.png/220px-Kakashi_Hatake.png'],
    ['Rock Lee','https://upload.wikimedia.org/wikipedia/en/thumb/e/e8/Rock_Lee.png/220px-Rock_Lee.png'],
    ['Neji','https://upload.wikimedia.org/wikipedia/en/thumb/f/fe/Neji_Hyuga.png/220px-Neji_Hyuga.png'],
    ['Hinata','https://upload.wikimedia.org/wikipedia/en/thumb/7/72/Hinata_Hy%C5%ABga.png/220px-Hinata_Hy%C5%ABga.png'],
    ['Shikamaru','https://upload.wikimedia.org/wikipedia/en/thumb/9/99/Shikamaru_Nara.png/220px-Shikamaru_Nara.png'],
    ['Gaara','https://upload.wikimedia.org/wikipedia/en/thumb/6/6c/Gaara_Naruto.png/220px-Gaara_Naruto.png'],
    ['Minato','https://upload.wikimedia.org/wikipedia/en/thumb/d/d5/Minato_Namikaze.png/220px-Minato_Namikaze.png'],
    ['Tsunade','https://upload.wikimedia.org/wikipedia/en/thumb/2/2d/Tsunade_Naruto.png/220px-Tsunade_Naruto.png'],
    ['Jiraiya','https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/Jiraiya_Naruto.png/220px-Jiraiya_Naruto.png'],
    ['Orochimaru','https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Orochimaru_Naruto.png/220px-Orochimaru_Naruto.png'],
    ['Itachi','https://upload.wikimedia.org/wikipedia/en/thumb/b/bd/Itachi_Uchiha.png/220px-Itachi_Uchiha.png'],
    ['Madara','https://upload.wikimedia.org/wikipedia/en/thumb/9/98/Madara_Uchiha.png/220px-Madara_Uchiha.png'],
    ['Pain','https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Pain_Naruto.png/220px-Pain_Naruto.png'],
    ['Obito','https://upload.wikimedia.org/wikipedia/en/thumb/7/72/Obito_Uchiha.png/220px-Obito_Uchiha.png'],
    ['Hashirama','https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/Hashirama_Senju.png/220px-Hashirama_Senju.png'],
    ['Tobirama','https://upload.wikimedia.org/wikipedia/en/thumb/e/e4/Tobirama_Senju.png/220px-Tobirama_Senju.png'],
    ['Deidara','https://upload.wikimedia.org/wikipedia/en/thumb/e/ec/Deidara_Naruto.png/220px-Deidara_Naruto.png'],
    ['Konan','https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Konan_Naruto.png/220px-Konan_Naruto.png'],
    ['Temari','https://upload.wikimedia.org/wikipedia/en/thumb/e/e9/Temari_Naruto.png/220px-Temari_Naruto.png'],
    ['Kushina','https://upload.wikimedia.org/wikipedia/en/thumb/3/3a/Kushina_Uzumaki.png/220px-Kushina_Uzumaki.png'],
    ['Karin','https://upload.wikimedia.org/wikipedia/en/thumb/6/6e/Karin_Naruto.png/220px-Karin_Naruto.png'],
    ['Killer Bee','https://upload.wikimedia.org/wikipedia/en/thumb/1/1c/Killer_Bee_Naruto.png/220px-Killer_Bee_Naruto.png'],
    ['Mei Terumi','https://upload.wikimedia.org/wikipedia/en/thumb/4/47/Mei_Terumi_Naruto.png/220px-Mei_Terumi_Naruto.png'],
    ['Shisui','https://upload.wikimedia.org/wikipedia/en/thumb/f/f0/Shisui_Uchiha.png/220px-Shisui_Uchiha.png'],
    ['Kisame','https://upload.wikimedia.org/wikipedia/en/thumb/6/68/Kisame_Hoshigaki.png/220px-Kisame_Hoshigaki.png'],
    ['Sasori','https://upload.wikimedia.org/wikipedia/en/thumb/f/fc/Sasori_Naruto.png/220px-Sasori_Naruto.png'],
    ['Ino','https://upload.wikimedia.org/wikipedia/en/thumb/7/71/Ino_Yamanaka.png/220px-Ino_Yamanaka.png'],
    ['Guy','https://upload.wikimedia.org/wikipedia/en/thumb/3/31/Might_Guy.png/220px-Might_Guy.png'],
  ];

  total += await add('Naruto','Konoha Ninja',[naChars[0],naChars[1],naChars[2],naChars[3],naChars[4],naChars[5],naChars[6],naChars[7],naChars[8],naChars[9],naChars[10],naChars[11],naChars[12],naChars[29],naChars[30]]);
  total += await add('Naruto','Akatsuki',[naChars[15],naChars[13],naChars[27],naChars[20],naChars[19],naChars[28],naChars[16],
    ['Hidan','https://upload.wikimedia.org/wikipedia/en/thumb/b/b0/Hidan_Naruto.png/220px-Hidan_Naruto.png'],
    ['Kakuzu','https://upload.wikimedia.org/wikipedia/en/thumb/6/6a/Kakuzu_Naruto.png/220px-Kakuzu_Naruto.png'],
    ['Zetsu','https://upload.wikimedia.org/wikipedia/en/thumb/2/27/Zetsu_Naruto.png/220px-Zetsu_Naruto.png'],
  ]);
  total += await add('Naruto','Uchiha Clan',[naChars[13],naChars[1],naChars[16],naChars[14],naChars[26]]);
  total += await add('Naruto','Kage',[naChars[17],naChars[18],naChars[9],naChars[10],naChars[3],naChars[0],naChars[8],naChars[25]]);
  total += await add('Naruto','Legendäre Sannin',[naChars[11],naChars[10],naChars[12]]);
  total += await add('Naruto','Jinchuuriki',[naChars[0],naChars[8],naChars[24],
    ['Yagura','https://upload.wikimedia.org/wikipedia/en/thumb/8/82/Yagura_Naruto.png/220px-Yagura_Naruto.png'],
    ['Utakata','https://upload.wikimedia.org/wikipedia/en/thumb/5/59/Utakata_Naruto.png/220px-Utakata_Naruto.png'],
  ]);
  total += await add('Naruto','Frauen',[naChars[2],naChars[6],naChars[29],naChars[10],naChars[20],naChars[21],naChars[22],naChars[25],naChars[23]]);
  total += await add('Naruto','Alle Charaktere', naChars.slice(0,20));
  total += await add('Naruto','Arcs',[
    ['Chunin Exam Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Invasion of Konoha Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Retrieval Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Kazekage Rescue Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Hidan & Kakuzu Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Itachi Pursuit Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Pain Assault Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Five Kage Summit Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Fourth Great Ninja War','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
    ['Kaguya Arc','https://images.weserv.nl/?url=cdn.myanimelist.net/images/anime/13/17405.jpg&w=200&h=280&fit=cover'],
  ]);
  console.log('✅ Naruto');

  // ═══════════════════════════════════════════════════════════
  // POKEMON — PokeAPI direkt (CORS-frei ✅)
  // ═══════════════════════════════════════════════════════════
  total += await add('Pokémon','Alle Starter',[
    ['Bisasam','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png'],
    ['Glumanda','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png'],
    ['Glurak','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png'],
    ['Schiggy','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/7.png'],
    ['Turtok','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png'],
    ['Endivie','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/152.png'],
    ['Feurigel','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/155.png'],
    ['Karnimani','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/158.png'],
    ['Geckarbor','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/252.png'],
    ['Flemmli','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/255.png'],
    ['Hydropi','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/258.png'],
    ['Chelast','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/387.png'],
    ['Panflam','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/390.png'],
    ['Plinfa','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/393.png'],
    ['Igamaro','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/495.png'],
    ['Floink','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/498.png'],
    ['Ottaro','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/501.png'],
    ['Froxy','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/650.png'],
    ['Fynx','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/653.png'],
    ['Bauz','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/722.png'],
    ['Flamiau','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/725.png'],
    ['Robball','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/728.png'],
    ['Chimpep','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/810.png'],
    ['Hopplo','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/813.png'],
    ['Memmeon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/816.png'],
    ['Felori','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/906.png'],
    ['Krokel','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/909.png'],
    ['Kwaks','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/912.png'],
  ]);
  total += await add('Pokémon','Generation 1',[
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
    ['Lapras','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/131.png'],
    ['Aerodactyl','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/142.png'],
    ['Nidoking','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/34.png'],
    ['Machomei','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/68.png'],
  ]);
  total += await add('Pokémon','Generation 2',[
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
  ]);
  total += await add('Pokémon','Generation 3',[
    ['Geckarbor','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/252.png'],
    ['Flemmli','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/255.png'],
    ['Hydropi','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/258.png'],
    ['Rayquaza','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/384.png'],
    ['Groudon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/383.png'],
    ['Kyogre','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/382.png'],
    ['Latios','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/381.png'],
    ['Latias','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/380.png'],
    ['Metagross','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/376.png'],
    ['Gardevoir','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/282.png'],
  ]);
  total += await add('Pokémon','Generation 4',[
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
  ]);
  total += await add('Pokémon','Legendäre',[
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
  ]);
  total += await add('Pokémon','Alle Pokémon',[
    ['Pikachu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png'],
    ['Glurak','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png'],
    ['Mewtu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/150.png'],
    ['Gengar','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/94.png'],
    ['Evoli','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/133.png'],
    ['Relaxo','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/143.png'],
    ['Lucario','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/448.png'],
    ['Rayquaza','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/384.png'],
    ['Dragoran','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/149.png'],
    ['Garados','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/130.png'],
    ['Tyranitar','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/248.png'],
    ['Garchomp','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/445.png'],
    ['Arceus','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/493.png'],
    ['Dialga','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/483.png'],
    ['Lugia','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/249.png'],
    ['Zacian','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/888.png'],
    ['Miraidon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1008.png'],
    ['Bisasam','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png'],
    ['Schiggy','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/7.png'],
    ['Lapras','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/131.png'],
  ]);
  total += await add('Pokémon','Typ: Feuer',[
    ['Glumanda','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png'],
    ['Glurak','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png'],
    ['Feurigel','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/155.png'],
    ['Typhlosion','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/157.png'],
    ['Flemmli','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/255.png'],
    ['Lohgock','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/257.png'],
    ['Panflam','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/390.png'],
    ['Infernape','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/392.png'],
    ['Arkani','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/59.png'],
    ['Magmar','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/126.png'],
  ]);
  total += await add('Pokémon','Typ: Wasser',[
    ['Schiggy','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/7.png'],
    ['Turtok','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png'],
    ['Karnimani','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/158.png'],
    ['Impergator','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/160.png'],
    ['Hydropi','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/258.png'],
    ['Garados','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/130.png'],
    ['Lapras','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/131.png'],
    ['Kyogre','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/382.png'],
    ['Plinfa','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/393.png'],
    ['Empoleon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/395.png'],
  ]);
  total += await add('Pokémon','Typ: Elektro',[
    ['Pikachu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png'],
    ['Raichu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/26.png'],
    ['Ampharos','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/181.png'],
    ['Raikou','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/243.png'],
    ['Elektek','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/125.png'],
    ['Jolteon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/135.png'],
    ['Luxray','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/405.png'],
    ['Zekrom','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/644.png'],
    ['Tapu Koko','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/785.png'],
    ['Magneton','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/82.png'],
  ]);
  total += await add('Pokémon','Typ: Drache',[
    ['Dragoran','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/149.png'],
    ['Dragonair','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/148.png'],
    ['Latios','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/381.png'],
    ['Latias','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/380.png'],
    ['Rayquaza','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/384.png'],
    ['Dialga','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/483.png'],
    ['Palkia','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/484.png'],
    ['Giratina','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/487.png'],
    ['Garchomp','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/445.png'],
    ['Haxorus','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/612.png'],
  ]);
  console.log('✅ Pokémon');

  // ═══════════════════════════════════════════════════════════
  // FUSSBALL — Wikipedia ✅
  // ═══════════════════════════════════════════════════════════
  total += await add('Fußball','Bundesliga',[
    ['FC Bayern München','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282002%E2%80%932017%29.svg/240px-FC_Bayern_M%C3%BCnchen_logo_%282002%E2%80%932017%29.svg.png'],
    ['Borussia Dortmund','https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Borussia_Dortmund_logo.svg/240px-Borussia_Dortmund_logo.svg.png'],
    ['Bayer Leverkusen','https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Bayer_04_Leverkusen_logo.svg/240px-Bayer_04_Leverkusen_logo.svg.png'],
    ['RB Leipzig','https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/RB_Leipzig_2014_logo.svg/240px-RB_Leipzig_2014_logo.svg.png'],
    ['Eintracht Frankfurt','https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Eintracht_Frankfurt_Logo.svg/240px-Eintracht_Frankfurt_Logo.svg.png'],
    ['VfB Stuttgart','https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/VfB_Stuttgart_1893_Logo.svg/240px-VfB_Stuttgart_1893_Logo.svg.png'],
    ['Werder Bremen','https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/SV-Werder-Bremen-Logo.svg/240px-SV-Werder-Bremen-Logo.svg.png'],
    ['SC Freiburg','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/SC_Freiburg_Logo.svg/240px-SC_Freiburg_Logo.svg.png'],
    ['Union Berlin','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/1._FC_Union_Berlin_Logo.svg/240px-1._FC_Union_Berlin_Logo.svg.png'],
    ['Hamburger SV','https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/HSV_Logo.svg/240px-HSV_Logo.svg.png'],
    ['Borussia Mönchengladbach','https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Borussia_M%C3%B6nchengladbach_logo.svg/240px-Borussia_M%C3%B6nchengladbach_logo.svg.png'],
    ['TSG Hoffenheim','https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/TSG_1899_Hoffenheim_logo.svg/240px-TSG_1899_Hoffenheim_logo.svg.png'],
  ]);
  total += await add('Fußball','Premier League',[
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
  ]);
  total += await add('Fußball','La Liga',[
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
  ]);
  total += await add('Fußball','Serie A',[
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
  ]);
  total += await add('Fußball','Ligue 1',[
    ['Paris Saint-Germain','https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Paris_Saint-Germain_F.C..svg/240px-Paris_Saint-Germain_F.C..svg.png'],
    ['Olympique Marseille','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Olympique_Marseille_logo.svg/240px-Olympique_Marseille_logo.svg.png'],
    ['Olympique Lyon','https://upload.wikimedia.org/wikipedia/en/thumb/6/6c/Olympique_Lyonnais.svg/240px-Olympique_Lyonnais.svg.png'],
    ['AS Monaco','https://upload.wikimedia.org/wikipedia/en/thumb/e/ea/AS_Monaco_FC.svg/240px-AS_Monaco_FC.svg.png'],
    ['Lille OSC','https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/LOSC_Lille_logo.svg/240px-LOSC_Lille_logo.svg.png'],
    ['RC Lens','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/RC_Lens_logo_2023.svg/240px-RC_Lens_logo_2023.svg.png'],
    ['OGC Nice','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/OGC_Nice_logo.svg/240px-OGC_Nice_logo.svg.png'],
    ['Nantes','https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/FC_Nantes_%28logo%29.svg/240px-FC_Nantes_%28logo%29.svg.png'],
    ['Stade Rennais','https://upload.wikimedia.org/wikipedia/en/thumb/a/a8/Stade_Rennais_FC.svg/240px-Stade_Rennais_FC.svg.png'],
    ['Strasbourg','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/RC_Strasbourg_Alsace_logo.svg/240px-RC_Strasbourg_Alsace_logo.svg.png'],
  ]);
  total += await add('Fußball','Alle Top-Vereine',[
    ['FC Bayern München','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282002%E2%80%932017%29.svg/240px-FC_Bayern_M%C3%BCnchen_logo_%282002%E2%80%932017%29.svg.png'],
    ['Borussia Dortmund','https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Borussia_Dortmund_logo.svg/240px-Borussia_Dortmund_logo.svg.png'],
    ['Real Madrid','https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Real_Madrid_CF.svg/240px-Real_Madrid_CF.svg.png'],
    ['FC Barcelona','https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/240px-FC_Barcelona_%28crest%29.svg.png'],
    ['Manchester City','https://upload.wikimedia.org/wikipedia/en/thumb/e/eb/Manchester_City_FC_badge.svg/240px-Manchester_City_FC_badge.svg.png'],
    ['Liverpool','https://upload.wikimedia.org/wikipedia/en/thumb/0/0c/Liverpool_FC.svg/240px-Liverpool_FC.svg.png'],
    ['Arsenal','https://upload.wikimedia.org/wikipedia/en/thumb/5/53/Arsenal_FC.svg/240px-Arsenal_FC.svg.png'],
    ['Manchester United','https://upload.wikimedia.org/wikipedia/en/thumb/7/7a/Manchester_United_FC_crest.svg/240px-Manchester_United_FC_crest.svg.png'],
    ['Chelsea','https://upload.wikimedia.org/wikipedia/en/thumb/c/cc/Chelsea_FC.svg/240px-Chelsea_FC.svg.png'],
    ['Paris Saint-Germain','https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Paris_Saint-Germain_F.C..svg/240px-Paris_Saint-Germain_F.C..svg.png'],
    ['Juventus','https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Juventus_FC_2017_logo.svg/240px-Juventus_FC_2017_logo.svg.png'],
    ['Inter Mailand','https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/FC_Internazionale_Milano_2021.svg/240px-FC_Internazionale_Milano_2021.svg.png'],
    ['AC Mailand','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Logo_of_AC_Milan.svg/240px-Logo_of_AC_Milan.svg.png'],
    ['Atletico Madrid','https://upload.wikimedia.org/wikipedia/en/thumb/f/f4/Atletico_Madrid_2017_logo.svg/240px-Atletico_Madrid_2017_logo.svg.png'],
    ['Napoli','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/SSC_Napoli.svg/240px-SSC_Napoli.svg.png'],
    ['Bayer Leverkusen','https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Bayer_04_Leverkusen_logo.svg/240px-Bayer_04_Leverkusen_logo.svg.png'],
    ['Olympique Marseille','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Olympique_Marseille_logo.svg/240px-Olympique_Marseille_logo.svg.png'],
    ['Tottenham','https://upload.wikimedia.org/wikipedia/en/thumb/b/b4/Tottenham_Hotspur.svg/240px-Tottenham_Hotspur.svg.png'],
    ['AS Roma','https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/AS_Roma_logo_%282013%29.svg/240px-AS_Roma_logo_%282013%29.svg.png'],
    ['RB Leipzig','https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/RB_Leipzig_2014_logo.svg/240px-RB_Leipzig_2014_logo.svg.png'],
  ]);
  total += await add('Fußball','Aktuelle Stars',[
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
    ['Joshua Kimmich','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Joshua_Kimmich_2018_%28cropped%29.jpg/240px-Joshua_Kimmich_2018_%28cropped%29.jpg'],
    ['Rodri','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Rodri_%28cropped%29.jpg/240px-Rodri_%28cropped%29.jpg'],
    ['Declan Rice','https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Declan_Rice_2023_%28cropped%29.jpg/240px-Declan_Rice_2023_%28cropped%29.jpg'],
    ['Cole Palmer','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Cole_Palmer_2023_%28cropped%29.jpg/240px-Cole_Palmer_2023_%28cropped%29.jpg'],
    ['Robert Lewandowski','https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Robert_Lewandowski%2C_FC_Bayern_M%C3%BCnchen_%28by_Augustas_Didzgalvis%29_%28cropped%29.jpg/240px-Robert_Lewandowski%2C_FC_Bayern_M%C3%BCnchen_%28by_Augustas_Didzgalvis%29_%28cropped%29.jpg'],
    ['Neymar Jr.','https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Neymar_2022_%28cropped%29.jpg/240px-Neymar_2022_%28cropped%29.jpg'],
    ['Toni Kroos','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Toni_Kroos_2018_%28cropped%29.jpg/240px-Toni_Kroos_2018_%28cropped%29.jpg'],
    ['Lautaro Martinez','https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Lautaro_Martinez_2022_%28cropped%29.jpg/240px-Lautaro_Martinez_2022_%28cropped%29.jpg'],
  ]);
  total += await add('Fußball','Legenden',[
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
  ]);
  total += await add('Fußball','Alle Spieler',[
    ['Lionel Messi','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg/240px-Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg'],
    ['Cristiano Ronaldo','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Cristiano_Ronaldo_2018_%28cropped%29.jpg/240px-Cristiano_Ronaldo_2018_%28cropped%29.jpg'],
    ['Erling Haaland','https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Erling_Haaland%2C_Man_City_vs_West_Ham_%28cropped%29.jpg/240px-Erling_Haaland%2C_Man_City_vs_West_Ham_%28cropped%29.jpg'],
    ['Kylian Mbappé','https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/2019-07-17_SG_Dynamo_Dresden_vs._Paris_Saint-Germain_by_Sandro_Halank%E2%80%93049_%28cropped%29.jpg/240px-2019-07-17_SG_Dynamo_Dresden_vs._Paris_Saint-Germain_by_Sandro_Halank%E2%80%93049_%28cropped%29.jpg'],
    ['Pelé','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Pel%C3%A9_1970.jpg/240px-Pel%C3%A9_1970.jpg'],
    ['Diego Maradona','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Maradona-Mundial_86_con_la_copa.JPG/240px-Maradona-Mundial_86_con_la_copa.JPG'],
    ['Zinedine Zidane','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Zinedine_Zidane_by_Tasnim_03.jpg/240px-Zinedine_Zidane_by_Tasnim_03.jpg'],
    ['Ronaldinho','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Ronaldinho_2018.jpg/240px-Ronaldinho_2018.jpg'],
    ['Jamal Musiala','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Jamal_Musiala_2022_%28cropped%29.jpg/240px-Jamal_Musiala_2022_%28cropped%29.jpg'],
    ['Florian Wirtz','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Florian_Wirtz_2023_%28cropped%29.jpg/240px-Florian_Wirtz_2023_%28cropped%29.jpg'],
    ['Vinicius Jr.','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Vinicius_Jr_2022_%28cropped%29.jpg/240px-Vinicius_Jr_2022_%28cropped%29.jpg'],
    ['Mohamed Salah','https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Mohamed_Salah_2018_%28cropped%29.jpg/240px-Mohamed_Salah_2018_%28cropped%29.jpg'],
    ['Jude Bellingham','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Jude_Bellingham_2023_%28cropped%29.jpg/240px-Jude_Bellingham_2023_%28cropped%29.jpg'],
    ['Harry Kane','https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Harry_Kane_2022_%28cropped%29.jpg/240px-Harry_Kane_2022_%28cropped%29.jpg'],
    ['Thierry Henry','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Thierry_Henry_2012.jpg/240px-Thierry_Henry_2012.jpg'],
    ['Paolo Maldini','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Paolo_Maldini_%28cropped%29.jpg/240px-Paolo_Maldini_%28cropped%29.jpg'],
    ['Pedri','https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Pedri_%28cropped%29.jpg/240px-Pedri_%28cropped%29.jpg'],
    ['Bukayo Saka','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Bukayo_Saka_%28cropped%29.jpg/240px-Bukayo_Saka_%28cropped%29.jpg'],
    ['Kevin De Bruyne','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Kevin_De_Bruyne_2018_%28cropped%29.jpg/240px-Kevin_De_Bruyne_2018_%28cropped%29.jpg'],
    ['Lamine Yamal','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Lamine_Yamal_2024_%28cropped%29.jpg/240px-Lamine_Yamal_2024_%28cropped%29.jpg'],
  ]);
  total += await add('Fußball','Bundesliga Stars',[
    ['Harry Kane','https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Harry_Kane_2022_%28cropped%29.jpg/240px-Harry_Kane_2022_%28cropped%29.jpg'],
    ['Jamal Musiala','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Jamal_Musiala_2022_%28cropped%29.jpg/240px-Jamal_Musiala_2022_%28cropped%29.jpg'],
    ['Florian Wirtz','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Florian_Wirtz_2023_%28cropped%29.jpg/240px-Florian_Wirtz_2023_%28cropped%29.jpg'],
    ['Joshua Kimmich','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Joshua_Kimmich_2018_%28cropped%29.jpg/240px-Joshua_Kimmich_2018_%28cropped%29.jpg'],
    ['Manuel Neuer','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Manuel_Neuer_2018_%28cropped%29.jpg/240px-Manuel_Neuer_2018_%28cropped%29.jpg'],
    ['Thomas Müller','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Thomas_M%C3%BCller_2018_%28cropped%29.jpg/240px-Thomas_M%C3%BCller_2018_%28cropped%29.jpg'],
    ['Marco Reus','https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Marco_Reus_2018_%28cropped%29.jpg/240px-Marco_Reus_2018_%28cropped%29.jpg'],
    ['Kai Havertz','https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Kai_Havertz_2019_%28cropped%29.jpg/240px-Kai_Havertz_2019_%28cropped%29.jpg'],
    ['Ilkay Gündogan','https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Ilkay_Gundogan_2018_%28cropped%29.jpg/240px-Ilkay_Gundogan_2018_%28cropped%29.jpg'],
    ['Leroy Sané','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Leroy_San%C3%A9_2018_%28cropped%29.jpg/240px-Leroy_San%C3%A9_2018_%28cropped%29.jpg'],
    ['Serge Gnabry','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Serge_Gnabry_2019_%28cropped%29.jpg/240px-Serge_Gnabry_2019_%28cropped%29.jpg'],
    ['Leon Goretzka','https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Leon_Goretzka_2019_%28cropped%29.jpg/240px-Leon_Goretzka_2019_%28cropped%29.jpg'],
  ]);
  total += await add('Fußball','Premier League Stars',[
    ['Mohamed Salah','https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Mohamed_Salah_2018_%28cropped%29.jpg/240px-Mohamed_Salah_2018_%28cropped%29.jpg'],
    ['Erling Haaland','https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Erling_Haaland%2C_Man_City_vs_West_Ham_%28cropped%29.jpg/240px-Erling_Haaland%2C_Man_City_vs_West_Ham_%28cropped%29.jpg'],
    ['Kevin De Bruyne','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Kevin_De_Bruyne_2018_%28cropped%29.jpg/240px-Kevin_De_Bruyne_2018_%28cropped%29.jpg'],
    ['Bukayo Saka','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Bukayo_Saka_%28cropped%29.jpg/240px-Bukayo_Saka_%28cropped%29.jpg'],
    ['Phil Foden','https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Phil_Foden_%28cropped%29.jpg/240px-Phil_Foden_%28cropped%29.jpg'],
    ['Declan Rice','https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Declan_Rice_2023_%28cropped%29.jpg/240px-Declan_Rice_2023_%28cropped%29.jpg'],
    ['Cole Palmer','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Cole_Palmer_2023_%28cropped%29.jpg/240px-Cole_Palmer_2023_%28cropped%29.jpg'],
    ['Virgil van Dijk','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Virgil_van_Dijk_2018_%28cropped%29.jpg/240px-Virgil_van_Dijk_2018_%28cropped%29.jpg'],
    ['Bruno Fernandes','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Bruno_Fernandes_2020_%28cropped%29.jpg/240px-Bruno_Fernandes_2020_%28cropped%29.jpg'],
    ['Alexander Isak','https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Alexander_Isak_2023_%28cropped%29.jpg/240px-Alexander_Isak_2023_%28cropped%29.jpg'],
    ['Marcus Rashford','https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Marcus_Rashford_2019_%28cropped%29.jpg/240px-Marcus_Rashford_2019_%28cropped%29.jpg'],
  ]);
  total += await add('Fußball','La Liga Stars',[
    ['Vinicius Jr.','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Vinicius_Jr_2022_%28cropped%29.jpg/240px-Vinicius_Jr_2022_%28cropped%29.jpg'],
    ['Jude Bellingham','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Jude_Bellingham_2023_%28cropped%29.jpg/240px-Jude_Bellingham_2023_%28cropped%29.jpg'],
    ['Pedri','https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Pedri_%28cropped%29.jpg/240px-Pedri_%28cropped%29.jpg'],
    ['Gavi','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Gavi_%28cropped%29.jpg/240px-Gavi_%28cropped%29.jpg'],
    ['Lamine Yamal','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Lamine_Yamal_2024_%28cropped%29.jpg/240px-Lamine_Yamal_2024_%28cropped%29.jpg'],
    ['Toni Kroos','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Toni_Kroos_2018_%28cropped%29.jpg/240px-Toni_Kroos_2018_%28cropped%29.jpg'],
    ['Kylian Mbappé','https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/2019-07-17_SG_Dynamo_Dresden_vs._Paris_Saint-Germain_by_Sandro_Halank%E2%80%93049_%28cropped%29.jpg/240px-2019-07-17_SG_Dynamo_Dresden_vs._Paris_Saint-Germain_by_Sandro_Halank%E2%80%93049_%28cropped%29.jpg'],
    ['Jan Oblak','https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Jan_Oblak_2019_%28cropped%29.jpg/240px-Jan_Oblak_2019_%28cropped%29.jpg'],
    ['Antoine Griezmann','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Antoine_Griezmann_2018_%28cropped%29.jpg/240px-Antoine_Griezmann_2018_%28cropped%29.jpg'],
    ['Robert Lewandowski','https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Robert_Lewandowski%2C_FC_Bayern_M%C3%BCnchen_%28by_Augustas_Didzgalvis%29_%28cropped%29.jpg/240px-Robert_Lewandowski%2C_FC_Bayern_M%C3%BCnchen_%28by_Augustas_Didzgalvis%29_%28cropped%29.jpg'],
  ]);
  console.log('✅ Fußball');

  // ═══════════════════════════════════════════════════════════
  // BOXEN — Wikipedia ✅
  // ═══════════════════════════════════════════════════════════
  const boxerList = [
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
  total += await add('Boxen','Alle Boxer', boxerList);
  total += await add('Boxen','Schwergewicht', boxerList.slice(0,10));
  total += await add('Boxen','Legenden', boxerList.slice(0,10));
  total += await add('Boxen','Mittelgewicht',[boxerList[7],boxerList[13],
    ['Oscar De La Hoya','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Oscar_De_La_Hoya_2010.jpg/240px-Oscar_De_La_Hoya_2010.jpg'],
    ['Ryan Garcia','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Ryan_Garcia_2022.jpg/240px-Ryan_Garcia_2022.jpg'],
    ['Gervonta Davis','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Gervonta_Davis_2022.jpg/240px-Gervonta_Davis_2022.jpg'],
    ['Deontay Wilder','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Deontay_Wilder_2019.jpg/240px-Deontay_Wilder_2019.jpg'],
    ['Sugar Ray Leonard','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Sugar_Ray_Leonard_1979.jpg/240px-Sugar_Ray_Leonard_1979.jpg'],
  ]);
  total += await add('Boxen','Aktuelle Champions',[boxerList[4],boxerList[5],boxerList[6],boxerList[7],
    ['Ryan Garcia','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Ryan_Garcia_2022.jpg/240px-Ryan_Garcia_2022.jpg'],
    ['Gervonta Davis','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Gervonta_Davis_2022.jpg/240px-Gervonta_Davis_2022.jpg'],
    ['Deontay Wilder','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Deontay_Wilder_2019.jpg/240px-Deontay_Wilder_2019.jpg'],
  ]);
  total += await add('Boxen','Deutsche Boxer',[
    ['Henry Maske','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Henry_Maske_2011.jpg/240px-Henry_Maske_2011.jpg'],
    ['Wladimir Klitschko','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Wladimir_Klitschko_2013.jpg/240px-Wladimir_Klitschko_2013.jpg'],
    ['Vitali Klitschko','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Vitali_Klitschko_2013.jpg/240px-Vitali_Klitschko_2013.jpg'],
    ['Felix Sturm','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Felix_Sturm_2010.jpg/240px-Felix_Sturm_2010.jpg'],
    ['Arthur Abraham','https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Arthur_Abraham_2013.jpg/240px-Arthur_Abraham_2013.jpg'],
    ['Sven Ottke','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Sven_Ottke_2008.jpg/240px-Sven_Ottke_2008.jpg'],
  ]);
  console.log('✅ Boxen');

  // ═══════════════════════════════════════════════════════════
  // ESSEN — Wikipedia ✅
  // ═══════════════════════════════════════════════════════════
  total += await add('Essen','Türkische Küche',[
    ['Döner Kebab','https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/D%C3%B6ner_Kebab.jpg/240px-D%C3%B6ner_Kebab.jpg'],
    ['Adana Kebab','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Adana_Kebab.jpg/320px-Adana_Kebab.jpg'],
    ['Iskender Kebab','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Iskender_kebab.jpg/320px-Iskender_kebab.jpg'],
    ['Köfte','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Turkish_kofte.jpg/320px-Turkish_kofte.jpg'],
    ['Lahmacun','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Lahmacun.jpg/320px-Lahmacun.jpg'],
    ['Pide','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Turkish_pide.jpg/320px-Turkish_pide.jpg'],
    ['Baklava','https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Baklava_-_Turkish_special%2C_80-ply.JPEG/320px-Baklava_-_Turkish_special%2C_80-ply.JPEG'],
    ['Künefe','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/K%C3%BCnefe.jpg/320px-K%C3%BCnefe.jpg'],
    ['Börek','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/B%C3%B6rek.jpg/320px-B%C3%B6rek.jpg'],
    ['Gözleme','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/G%C3%B6zleme.jpg/320px-G%C3%B6zleme.jpg'],
    ['Simit','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Simit_from_Istanbul.jpg/320px-Simit_from_Istanbul.jpg'],
    ['Mercimek Çorbası','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Mercimek_%C3%A7orbas%C4%B1.jpg/320px-Mercimek_%C3%A7orbas%C4%B1.jpg'],
    ['Menemen','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Menemen.jpg/320px-Menemen.jpg'],
    ['Cacık','https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cacik.jpg/320px-Cacik.jpg'],
    ['Ayran','https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Ayran.jpg/240px-Ayran.jpg'],
    ['Türkischer Tee','https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/A_small_cup_of_turkish_tea.jpg/240px-A_small_cup_of_turkish_tea.jpg'],
    ['Lokum','https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Turkish_delight.jpg/320px-Turkish_delight.jpg'],
    ['Yaprak Sarma','https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Dolmades.jpg/320px-Dolmades.jpg'],
    ['Mantı','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Manti.jpg/320px-Manti.jpg'],
    ['Hummus','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Hummus_from_The_Nile.jpg/320px-Hummus_from_The_Nile.jpg'],
  ]);
  total += await add('Essen','Italienische Küche',[
    ['Pizza Margherita','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg/320px-Eq_it-na_pizza-margherita_sep2005_sml.jpg'],
    ['Spaghetti Carbonara','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Fresh_made_Pasta_Carbonara.jpg/320px-Fresh_made_Pasta_Carbonara.jpg'],
    ['Lasagne','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Lasagna_-_stonesoup.jpg/320px-Lasagna_-_stonesoup.jpg'],
    ['Risotto','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Risotto_black.jpg/320px-Risotto_black.jpg'],
    ['Tiramisu','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Tiramisu_-_Raffaele_Diomede.jpg/320px-Tiramisu_-_Raffaele_Diomede.jpg'],
    ['Gnocchi','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Gnocchi_di_patate.jpg/320px-Gnocchi_di_patate.jpg'],
    ['Bruschetta','https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Bruschetta_with_tomatoes.jpg/320px-Bruschetta_with_tomatoes.jpg'],
    ['Panna Cotta','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Panna_cotta_with_strawberry_sauce.jpg/320px-Panna_cotta_with_strawberry_sauce.jpg'],
    ['Cannoli','https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cannoli.jpg/320px-Cannoli.jpg'],
    ['Focaccia','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Focaccia_Recco.jpg/320px-Focaccia_Recco.jpg'],
  ]);
  total += await add('Essen','Japanische Küche',[
    ['Sushi','https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Sushi_platter.jpg/320px-Sushi_platter.jpg'],
    ['Ramen','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Shoyu_Ramen.jpg/320px-Shoyu_Ramen.jpg'],
    ['Tempura','https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Tempura_Ebi.jpg/320px-Tempura_Ebi.jpg'],
    ['Tonkatsu','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Tonkatsu_with_miso_soup.jpg/320px-Tonkatsu_with_miso_soup.jpg'],
    ['Takoyaki','https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Takoyaki_01.jpg/320px-Takoyaki_01.jpg'],
    ['Gyoza','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Gyoza_dumplings.jpg/320px-Gyoza_dumplings.jpg'],
    ['Mochi','https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Mochi-daifuku.jpg/320px-Mochi-daifuku.jpg'],
    ['Udon','https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Udon_by_stu_spivack_in_Flickr.jpg/320px-Udon_by_stu_spivack_in_Flickr.jpg'],
    ['Onigiri','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Onigiri.jpg/320px-Onigiri.jpg'],
    ['Miso Suppe','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Miso_Soup.jpg/320px-Miso_Soup.jpg'],
    ['Yakitori','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Yakitori_2007.jpg/320px-Yakitori_2007.jpg'],
    ['Karaage','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Karaage.jpg/320px-Karaage.jpg'],
  ]);
  total += await add('Essen','Fast Food',[
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
  ]);
  total += await add('Essen','Desserts & Süßes',[
    ['Tiramisu','https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Tiramisu_-_Raffaele_Diomede.jpg/320px-Tiramisu_-_Raffaele_Diomede.jpg'],
    ['Cheesecake','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Cherry_cheesecake.jpg/320px-Cherry_cheesecake.jpg'],
    ['Macarons','https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Assorted_French_macarons.jpg/320px-Assorted_French_macarons.jpg'],
    ['Donut','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Glazed-Donut.jpg/320px-Glazed-Donut.jpg'],
    ['Brownie','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Brownies_%28homemade%29.jpg/320px-Brownies_%28homemade%29.jpg'],
    ['Waffeln','https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Wafels_%26_Dinges_-_Wafels_4_%284751580440%29.jpg/320px-Wafels_%26_Dinges_-_Wafels_4_%284751580440%29.jpg'],
    ['Mochi','https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Mochi-daifuku.jpg/320px-Mochi-daifuku.jpg'],
    ['Crêpes','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Crepe_suette_g%C3%A2teau.jpg/320px-Crepe_suette_g%C3%A2teau.jpg'],
    ['Churros','https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Churros_-_Evan_Swigart.jpg/320px-Churros_-_Evan_Swigart.jpg'],
    ['Baklava','https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Baklava_-_Turkish_special%2C_80-ply.JPEG/320px-Baklava_-_Turkish_special%2C_80-ply.JPEG'],
    ['Panna Cotta','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Panna_cotta_with_strawberry_sauce.jpg/320px-Panna_cotta_with_strawberry_sauce.jpg'],
    ['Eis','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Sundae_Supreme_%28cropped%29.jpg/240px-Sundae_Supreme_%28cropped%29.jpg'],
  ]);
  total += await add('Essen','Getränke',[
    ['Coca-Cola','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Coca-Cola_logo_red.svg/320px-Coca-Cola_logo_red.svg.png'],
    ['Fanta','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Fanta_logo_2021.svg/320px-Fanta_logo_2021.svg.png'],
    ['Sprite','https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Sprite_2022.svg/240px-Sprite_2022.svg.png'],
    ['Kaffee','https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/A_small_cup_of_coffee.JPG/240px-A_small_cup_of_coffee.JPG'],
    ['Orangensaft','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Orange_juice_1.jpg/240px-Orange_juice_1.jpg'],
    ['Ayran','https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Ayran.jpg/240px-Ayran.jpg'],
    ['Türkischer Tee','https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/A_small_cup_of_turkish_tea.jpg/240px-A_small_cup_of_turkish_tea.jpg'],
    ['Monster Energy','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Monster_Energy_drink_logo.svg/240px-Monster_Energy_drink_logo.svg.png'],
    ['Red Bull','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Redbull_logo.svg/320px-Redbull_logo.svg.png'],
    ['Milch','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Milk_glass.jpg/240px-Milk_glass.jpg'],
  ]);
  total += await add('Essen','Snacks',[
    ['Chips','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Potato-Chips.jpg/320px-Potato-Chips.jpg'],
    ['Popcorn','https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Popcorn.jpg/320px-Popcorn.jpg'],
    ['Gummibärchen','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Gummy_bears.jpg/320px-Gummy_bears.jpg'],
    ['Schokolade','https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Chocolate_%28blue_background%29.jpg/320px-Chocolate_%28blue_background%29.jpg'],
    ['Brezel','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Pretzel_on_white_background.jpg/320px-Pretzel_on_white_background.jpg'],
    ['Nachos','https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Nachos_2.jpg/320px-Nachos_2.jpg'],
    ['Nüsse','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Mixed_nuts_-_Mixed_nuts.jpg/320px-Mixed_nuts_-_Mixed_nuts.jpg'],
    ['Oreos','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Oreo_logo.svg/320px-Oreo_logo.svg.png'],
    ['M&Ms','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/M%26M_Candy_Logo.svg/320px-M%26M_Candy_Logo.svg.png'],
    ['Twix','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Twix_logo.svg/320px-Twix_logo.svg.png'],
  ]);
  total += await add('Essen','Chinesische Küche',[
    ['Dim Sum','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Dim_sum_-_Har_gow_%28dumplings%29.jpg/320px-Dim_sum_-_Har_gow_%28dumplings%29.jpg'],
    ['Peking Ente','https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Roast_Duck_%28Peking_style%29.jpg/320px-Roast_Duck_%28Peking_style%29.jpg'],
    ['Fried Rice','https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Fried_rice_2.jpg/320px-Fried_rice_2.jpg'],
    ['Hot Pot','https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Hot_pot_at_Xiabu_Xiabu.jpg/320px-Hot_pot_at_Xiabu_Xiabu.jpg'],
    ['Chow Mein','https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Chow_mein.jpg/320px-Chow_mein.jpg'],
    ['Spring Rolls','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Lumpia_Shanghai.jpg/320px-Lumpia_Shanghai.jpg'],
    ['Sweet & Sour Pork','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Sweet_and_sour_pork_001.jpg/320px-Sweet_and_sour_pork_001.jpg'],
    ['Dumplings','https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Boiled_dumplings.jpg/320px-Boiled_dumplings.jpg'],
    ['Kung Pao Chicken','https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Kung-pao-shanghai.jpg/320px-Kung-pao-shanghai.jpg'],
    ['Mapo Tofu','https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Sichuan_Peppercorn_Tofu_%288085196993%29.jpg/320px-Sichuan_Peppercorn_Tofu_%288085196993%29.jpg'],
  ]);
  total += await add('Essen','Amerikanische Küche',[
    ['Burger','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/RedDot_Burger.jpg/320px-RedDot_Burger.jpg'],
    ['Hot Dog','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Hot_dog_with_mustard.png/320px-Hot_dog_with_mustard.png'],
    ['BBQ Ribs','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Ribs_in_BBQ_sauce.jpg/320px-Ribs_in_BBQ_sauce.jpg'],
    ['Mac & Cheese','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/MacaroniCheese.jpg/320px-MacaroniCheese.jpg'],
    ['Buffalo Wings','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Buffalo_Wings.jpg/320px-Buffalo_Wings.jpg'],
    ['Apple Pie','https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Apple_pie.jpg/320px-Apple_pie.jpg'],
    ['Cheesesteak','https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Cheesesteak_2_by_Renee_Suen.jpg/320px-Cheesesteak_2_by_Renee_Suen.jpg'],
    ['Clam Chowder','https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/New_England_Clam_Chowder.jpg/320px-New_England_Clam_Chowder.jpg'],
    ['Corn Dogs','https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Corndogs.jpg/320px-Corndogs.jpg'],
    ['Pancakes','https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Pound_layer_cake.jpg/320px-Pound_layer_cake.jpg'],
  ]);
  total += await add('Essen','Mexikanische Küche',[
    ['Tacos','https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/001_Tacos_de_carnitas%2C_carne_asada_y_al_pastor.jpg/320px-001_Tacos_de_carnitas%2C_carne_asada_y_al_pastor.jpg'],
    ['Burritos','https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Burrito_with_rice.jpg/320px-Burrito_with_rice.jpg'],
    ['Nachos','https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Nachos_2.jpg/320px-Nachos_2.jpg'],
    ['Guacamole','https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Guacamole.jpg/320px-Guacamole.jpg'],
    ['Quesadilla','https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Quesadilla_2.jpg/320px-Quesadilla_2.jpg'],
    ['Enchiladas','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/A_Plate_of_Enchiladas.jpg/320px-A_Plate_of_Enchiladas.jpg'],
    ['Tamales','https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/MixedTamales.jpg/320px-MixedTamales.jpg'],
    ['Churros','https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Churros_-_Evan_Swigart.jpg/320px-Churros_-_Evan_Swigart.jpg'],
    ['Fajitas','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Chicken_fajitas.jpg/320px-Chicken_fajitas.jpg'],
    ['Salsa','https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Tomato_salsa_5.jpg/320px-Tomato_salsa_5.jpg'],
  ]);
  total += await add('Essen','Indische Küche',[
    ['Biryani','https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Biryani_Home_003.jpg/320px-Biryani_Home_003.jpg'],
    ['Naan','https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Naan_%28Garlic_Naan%29.jpg/320px-Naan_%28Garlic_Naan%29.jpg'],
    ['Samosa','https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Indian-Spiced_Cauliflower_and_Potato_Samosas_%285765444345%29.jpg/320px-Indian-Spiced_Cauliflower_and_Potato_Samosas_%285765444345%29.jpg'],
    ['Dal','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Dal_fry.jpg/320px-Dal_fry.jpg'],
    ['Palak Paneer','https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Palak_paneer.jpg/320px-Palak_paneer.jpg'],
    ['Mango Lassi','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Mango_lassi.jpg/320px-Mango_lassi.jpg'],
    ['Gulab Jamun','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Gulab_jamun_%28culture%29.jpg/320px-Gulab_jamun_%28culture%29.jpg'],
    ['Chapati','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Chapati_Kerala.jpg/320px-Chapati_Kerala.jpg'],
    ['Tandoori Chicken','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Tandoori_murgh.jpg/320px-Tandoori_murgh.jpg'],
    ['Butter Chicken','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Butter_chicken_curry.jpg/320px-Butter_chicken_curry.jpg'],
  ]);
  console.log('✅ Essen');

  // ═══════════════════════════════════════════════════════════
  // ORTE — Wikipedia ✅
  // ═══════════════════════════════════════════════════════════
  total += await add('Orte','Städte',[
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
  ]);
  total += await add('Orte','Sehenswürdigkeiten',[
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
  ]);
  total += await add('Orte','Strände',[
    ['Bora Bora','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Bora_Bora_by_Luka_Peternel.jpg/320px-Bora_Bora_by_Luka_Peternel.jpg'],
    ['Malediven','https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Male%27%2C_Maldives.jpg/320px-Male%27%2C_Maldives.jpg'],
    ['Ibiza','https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Ibiza_isla_blanca.jpg/320px-Ibiza_isla_blanca.jpg'],
    ['Santorini','https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Santorini_Sunset.jpg/320px-Santorini_Sunset.jpg'],
    ['Miami Beach','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Miami_Beach_Aerial.jpg/320px-Miami_Beach_Aerial.jpg'],
    ['Phuket','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Patong_Beach_Phuket_2009.jpg/320px-Patong_Beach_Phuket_2009.jpg'],
    ['Mallorca','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Palma_de_Mallorca%2C_Espa%C3%B1a_%2833066569026%29.jpg/320px-Palma_de_Mallorca%2C_Espa%C3%B1a_%2833066569026%29.jpg'],
    ['Hawaii','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Waikiki_Beach.jpg/320px-Waikiki_Beach.jpg'],
    ['Koh Samui','https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Koh_Samui_aerial.jpg/320px-Koh_Samui_aerial.jpg'],
  ]);
  total += await add('Orte','Berge',[
    ['Mount Everest','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Everest_North_Face_toward_Base_Camp_Tibet_Luca_Galuzzi_2006.jpg/320px-Everest_North_Face_toward_Base_Camp_Tibet_Luca_Galuzzi_2006.jpg'],
    ['Matterhorn','https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Matterhorn_from_Domh%C3%BCtte_-_2012-08.jpg/240px-Matterhorn_from_Domh%C3%BCtte_-_2012-08.jpg'],
    ['Kilimanjaro','https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Kilimanjaro_2.jpg/320px-Kilimanjaro_2.jpg'],
    ['Mont Blanc','https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Panorama_Mt_Blanc.jpg/320px-Panorama_Mt_Blanc.jpg'],
    ['Fuji','https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/080103_hakkai-san_fuji.jpg/320px-080103_hakkai-san_fuji.jpg'],
    ['Zugspitze','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Zugspitze_Alpspitze_Waxenstein_2.jpg/320px-Zugspitze_Alpspitze_Waxenstein_2.jpg'],
    ['K2','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/K2_2006b.jpg/240px-K2_2006b.jpg'],
    ['Denali','https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Denali_Mt_McKinley.jpg/320px-Denali_Mt_McKinley.jpg'],
  ]);
  total += await add('Orte','Inseln',[
    ['Malediven','https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Male%27%2C_Maldives.jpg/320px-Male%27%2C_Maldives.jpg'],
    ['Hawaii','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Waikiki_Beach.jpg/320px-Waikiki_Beach.jpg'],
    ['Santorini','https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Santorini_Sunset.jpg/320px-Santorini_Sunset.jpg'],
    ['Ibiza','https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Ibiza_isla_blanca.jpg/320px-Ibiza_isla_blanca.jpg'],
    ['Sizilien','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Palermo_Veduta.jpg/320px-Palermo_Veduta.jpg'],
    ['Kreta','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Heraklion_in_Crete.jpg/320px-Heraklion_in_Crete.jpg'],
    ['Jamaika','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Flag_of_Jamaica.svg/320px-Flag_of_Jamaica.svg.png'],
    ['Madagaskar','https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Nosy_Be_Madagascar.jpg/320px-Nosy_Be_Madagascar.jpg'],
    ['Island','https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Iceland_Landscape.jpg/320px-Iceland_Landscape.jpg'],
    ['Bali','https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Bali_Indonesia.jpg/320px-Bali_Indonesia.jpg'],
  ]);
  total += await add('Orte','Länder',[
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
  ]);
  console.log('✅ Orte');

  // ═══════════════════════════════════════════════════════════
  // SPORTARTEN — Wikipedia ✅
  // ═══════════════════════════════════════════════════════════
  total += await add('Sportarten','Ballsport',[
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
  ]);
  total += await add('Sportarten','Kampfsport',[
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
  ]);
  total += await add('Sportarten','Wintersport',[
    ['Skifahren','https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Alpine_skiing_pictogram.svg/240px-Alpine_skiing_pictogram.svg.png'],
    ['Snowboarden','https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Snowboard_pictogram.svg/240px-Snowboard_pictogram.svg.png'],
    ['Eishockey','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Ice_hockey_pictogram.svg/240px-Ice_hockey_pictogram.svg.png'],
    ['Biathlon','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Biathlon_pictogram.svg/240px-Biathlon_pictogram.svg.png'],
    ['Eiskunstlauf','https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Figure_skating_pictogram.svg/240px-Figure_skating_pictogram.svg.png'],
    ['Curling','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Curling_pictogram.svg/240px-Curling_pictogram.svg.png'],
    ['Bobfahren','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Bobsled_pictogram.svg/240px-Bobsled_pictogram.svg.png'],
  ]);
  total += await add('Sportarten','Motorsport',[
    ['Formel 1','https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/F1.svg/320px-F1.svg.png'],
    ['MotoGP','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Motorcycle_racing_pictogram.svg/240px-Motorcycle_racing_pictogram.svg.png'],
    ['NASCAR','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/NASCAR_logo.svg/320px-NASCAR_logo.svg.png'],
    ['Rally','https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Rally_car.jpg/320px-Rally_car.jpg'],
    ['Le Mans','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/24h_Le_Mans_logo.svg/320px-24h_Le_Mans_logo.svg.png'],
    ['DTM','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/DTM_logo.svg/320px-DTM_logo.svg.png'],
  ]);
  total += await add('Sportarten','Extremsport',[
    ['Skateboarden','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Skateboarding_pictogram.svg/240px-Skateboarding_pictogram.svg.png'],
    ['Bungee Jumping','https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Bungee_jumping.jpg/320px-Bungee_jumping.jpg'],
    ['Fallschirmspringen','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Skydiving_pictogram.svg/240px-Skydiving_pictogram.svg.png'],
    ['Free Climbing','https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Sport_climbing_pictogram.svg/240px-Sport_climbing_pictogram.svg.png'],
    ['BMX','https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/BMX_cycling_pictogram.svg/240px-BMX_cycling_pictogram.svg.png'],
    ['Wingsuit','https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Wingsuit_flying.jpg/320px-Wingsuit_flying.jpg'],
    ['Mountainbiking','https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Mountain_bike_pictogram.svg/240px-Mountain_bike_pictogram.svg.png'],
  ]);
  total += await add('Sportarten','Wassersport',[
    ['Schwimmen','https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Swimming_pictogram.svg/240px-Swimming_pictogram.svg.png'],
    ['Surfen','https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Surfing_pictogram.svg/240px-Surfing_pictogram.svg.png'],
    ['Tauchen','https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Scuba_diving_pictogram.svg/240px-Scuba_diving_pictogram.svg.png'],
    ['Kajak','https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Canoe_sprint_pictogram.svg/240px-Canoe_sprint_pictogram.svg.png'],
    ['Wasserball','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Water_polo_pictogram.svg/240px-Water_polo_pictogram.svg.png'],
    ['Rudern','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Rowing_pictogram.svg/240px-Rowing_pictogram.svg.png'],
    ['Kitesurfen','https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Kite_surfing_in_Kiel.jpg/320px-Kite_surfing_in_Kiel.jpg'],
  ]);
  total += await add('Sportarten','Leichtathletik',[
    ['100m Sprint','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Athletics_pictogram.svg/240px-Athletics_pictogram.svg.png'],
    ['Marathon','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Athletics_pictogram.svg/240px-Athletics_pictogram.svg.png'],
    ['Hochsprung','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/High_jump_pictogram.svg/240px-High_jump_pictogram.svg.png'],
    ['Weitsprung','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Athletics_pictogram.svg/240px-Athletics_pictogram.svg.png'],
    ['Speerwerfen','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Javelin_throw_pictogram.svg/240px-Javelin_throw_pictogram.svg.png'],
    ['Stabhochsprung','https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Pole_vault_pictogram.svg/240px-Pole_vault_pictogram.svg.png'],
    ['Diskuswurf','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Discus_throw_pictogram.svg/240px-Discus_throw_pictogram.svg.png'],
  ]);
  console.log('✅ Sportarten');

  console.log(`\n🎉 FERTIG! ${total} Items total`);
  process.exit(0);
}

fixAll().catch(err => { console.error('❌', err); process.exit(1); });