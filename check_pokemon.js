// check_pokemon.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function check() {
  // Finde "Alle Starter" Kategorie
  const cats = await db.collection('categories')
    .where('name', '==', 'Alle Starter').get();
  console.log('Alle Starter Kategorien:');
  cats.docs.forEach(d => console.log(d.id, d.data()));

  // Finde Items mit sub_category_id = erste gefundene ID
  if (cats.docs.length > 0) {
    const subId = cats.docs[0].id;
    const items = await db.collection('items')
      .where('sub_category_id', '==', subId).get();
    console.log(`\nItems mit sub_category_id ${subId}: ${items.size}`);
    items.docs.slice(0, 3).forEach(d => console.log(d.data().name, d.data().category_id));
  }
  process.exit(0);
}
check();