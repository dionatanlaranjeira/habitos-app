import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function run(): Promise<void> {
  console.log("Iniciando migração: habitIds -> selectedHabitIds...");

  const membersSnap = await db.collectionGroup("members").get();
  console.log(`Documentos de membros encontrados: ${membersSnap.size}`);

  let inspected = 0;
  let updated = 0;

  let batch = db.batch();
  let ops = 0;

  for (const doc of membersSnap.docs) {
    inspected += 1;
    const data = doc.data() as Record<string, unknown>;

    const selected = data.selectedHabitIds;
    const legacy = data.habitIds;

    const selectedList = Array.isArray(selected) ? selected : null;
    const legacyList = Array.isArray(legacy) ? legacy : null;

    if (!legacyList) {
      continue;
    }

    const nextSelected = selectedList ?? legacyList;

    batch.set(
      doc.ref,
      {
        selectedHabitIds: nextSelected,
        habitIds: admin.firestore.FieldValue.delete(),
      },
      {merge: true},
    );

    ops += 1;
    updated += 1;

    if (ops >= 400) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }

  if (ops > 0) {
    await batch.commit();
  }

  console.log(`Inspecionados: ${inspected}`);
  console.log(`Atualizados: ${updated}`);
  console.log("Migração concluída.");
}

run()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Erro na migração:", error);
    process.exit(1);
  });
