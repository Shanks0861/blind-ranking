const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function fix() {
  // Finde Fußball und Sportarten IDs
  const cats = await db.collection('categories').get();
  const catByName = {};
  cats.docs.forEach(d => catByName[d.data().name] = d.id);

  const fussballId = catByName['Fußball'];
  const sportartenId = catByName['Sportarten'];

  console.log('Fußball ID:', fussballId);
  console.log('Sportarten ID:', sportartenId);

  // Erstelle fehlende Unterkategorien
  const alleSpielerRef = await db.collection('categories').add({
    name: 'Alle Spieler', parent_id: fussballId
  });
  console.log('✅ "Alle Spieler" erstellt:', alleSpielerRef.id);

  const leichtathletikRef = await db.collection('categories').add({
    name: 'Leichtathletik', parent_id: sportartenId
  });
  console.log('✅ "Leichtathletik" erstellt:', leichtathletikRef.id);

  // Füge Items ein
  async function addItems(catId, subId, items) {
    const b = db.batch();
    for (const [name, url] of items) {
      const ref = db.collection('items').doc();
      b.set(ref, { name, category_id: catId, sub_category_id: subId, image_url: url || null });
    }
    await b.commit();
  }

  await addItems(fussballId, alleSpielerRef.id, [
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
  console.log('✅ Alle Spieler Items eingefügt');

  await addItems(sportartenId, leichtathletikRef.id, [
    ['100m Sprint','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Athletics_pictogram.svg/240px-Athletics_pictogram.svg.png'],
    ['Marathon','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Athletics_pictogram.svg/240px-Athletics_pictogram.svg.png'],
    ['Hochsprung','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/High_jump_pictogram.svg/240px-High_jump_pictogram.svg.png'],
    ['Weitsprung','https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Athletics_pictogram.svg/240px-Athletics_pictogram.svg.png'],
    ['Speerwerfen','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Javelin_throw_pictogram.svg/240px-Javelin_throw_pictogram.svg.png'],
    ['Stabhochsprung','https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Pole_vault_pictogram.svg/240px-Pole_vault_pictogram.svg.png'],
    ['Diskuswurf','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Discus_throw_pictogram.svg/240px-Discus_throw_pictogram.svg.png'],
  ]);
  console.log('✅ Leichtathletik Items eingefügt');

  console.log('\n🎉 Fertig!');
  process.exit(0);
}

fix().catch(err => { console.error('❌', err); process.exit(1); });