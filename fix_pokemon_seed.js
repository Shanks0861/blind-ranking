const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function fix() {
  const cats = await db.collection('categories').get();
  const catByName = {};
  cats.docs.forEach(d => catByName[d.data().name] = d.id);

  async function addItems(categoryName, subName, items) {
    const catId = catByName[categoryName];
    const subId = catByName[subName];
    if (!catId) { console.log('❌ Kategorie nicht gefunden:', categoryName); return; }
    if (!subId) { console.log('❌ Sub nicht gefunden:', subName); return; }
    const b = db.batch();
    for (const [name, url] of items) {
      const ref = db.collection('items').doc();
      b.set(ref, { name, category_id: catId, sub_category_id: subId, image_url: url || null });
    }
    await b.commit();
    console.log(`✅ ${subName} (${items.length} Items)`);
  }

  // One Piece Arcs
  await addItems('One Piece', 'Arcs', [
    ['Syrup Village Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Baratie Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Arlong Park Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Loguetown Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Alabasta Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Skypiea Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Water 7 Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Enies Lobby Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Thriller Bark Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Marineford Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Fishman Island Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Punk Hazard Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Dressrosa Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Whole Cake Island Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Wano Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
    ['Egghead Arc','https://cdn.myanimelist.net/images/anime/6/73245.jpg'],
  ]);

  // Naruto Arcs
  await addItems('Naruto', 'Arcs', [
    ['Chunin Exam Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Invasion of Konoha Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Sannin Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Sasuke Recovery Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Kazekage Rescue Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Hidan & Kakuzu Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Itachi Pursuit Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Pain Assault Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Five Kage Summit Arc','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
    ['Fourth Great Ninja War','https://cdn.myanimelist.net/images/anime/13/17405.jpg'],
  ]);

  // One Piece Pre/Post Timeskip
  await addItems('One Piece', 'Pre Timeskip', [
    ['Ruffy (Pre)','https://cdn.myanimelist.net/images/characters/9/310307.jpg'],
    ['Zoro (Pre)','https://cdn.myanimelist.net/images/characters/3/100534.jpg'],
    ['Nami (Pre)','https://cdn.myanimelist.net/images/characters/9/112263.jpg'],
    ['Sanji (Pre)','https://cdn.myanimelist.net/images/characters/11/174521.jpg'],
    ['Chopper (Pre)','https://cdn.myanimelist.net/images/characters/3/272334.jpg'],
    ['Robin (Pre)','https://cdn.myanimelist.net/images/characters/2/225811.jpg'],
    ['Franky (Pre)','https://cdn.myanimelist.net/images/characters/9/131742.jpg'],
    ['Brook (Pre)','https://cdn.myanimelist.net/images/characters/4/130573.jpg'],
    ['Lysop (Pre)','https://cdn.myanimelist.net/images/characters/9/131317.jpg'],
  ]);

  await addItems('One Piece', 'Post Timeskip', [
    ['Ruffy (Post)','https://cdn.myanimelist.net/images/characters/9/310307.jpg'],
    ['Zoro (Post)','https://cdn.myanimelist.net/images/characters/3/100534.jpg'],
    ['Nami (Post)','https://cdn.myanimelist.net/images/characters/9/112263.jpg'],
    ['Sanji (Post)','https://cdn.myanimelist.net/images/characters/11/174521.jpg'],
    ['Chopper (Post)','https://cdn.myanimelist.net/images/characters/3/272334.jpg'],
    ['Robin (Post)','https://cdn.myanimelist.net/images/characters/2/225811.jpg'],
    ['Franky (Post)','https://cdn.myanimelist.net/images/characters/9/131742.jpg'],
    ['Brook (Post)','https://cdn.myanimelist.net/images/characters/4/130573.jpg'],
    ['Lysop (Post)','https://cdn.myanimelist.net/images/characters/9/131317.jpg'],
    ['Jinbe','https://cdn.myanimelist.net/images/characters/3/49734.jpg'],
  ]);

  // Pokemon Typ-Kategorien
  await addItems('Pokémon', 'Typ: Feuer', [
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

  await addItems('Pokémon', 'Typ: Wasser', [
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

  await addItems('Pokémon', 'Typ: Elektro', [
    ['Pikachu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png'],
    ['Raichu','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/26.png'],
    ['Ampharos','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/181.png'],
    ['Raikou','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/243.png'],
    ['Elektek','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/125.png'],
    ['Magneton','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/82.png'],
    ['Jolteon','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/135.png'],
    ['Luxray','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/405.png'],
    ['Zekrom','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/644.png'],
    ['Tapu Koko','https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/785.png'],
  ]);

  await addItems('Pokémon', 'Typ: Drache', [
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

  console.log('\n🎉 Fertig!');
  process.exit(0);
}

fix().catch(err => { console.error('❌', err); process.exit(1); });