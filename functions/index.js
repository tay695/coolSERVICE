const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notificarFuncionario = functions.firestore
  .document("ordens_servico/{osId}")
  .onCreate(async (snap, context) => {
    const os = snap.data();
    const employeeId = os.employeeId;

    if (!employeeId) return null;

    // Busca o funcionário pelo id
    const snapshot = await admin.firestore()
      .collection("funcionarios")
      .where("id", "==", employeeId)
      .limit(1)
      .get();

    if (snapshot.empty) return null;

    const funcionario = snapshot.docs[0].data();
    const fcmToken = funcionario.fcmToken;

    if (!fcmToken) return null;

    // Envia notificação push
    const message = {
      token: fcmToken,
      notification: {
        title: "Nova Ordem de Serviço",
        body: "Você foi alocado em uma nova OS. Verifique o aplicativo.",
      },
      android: {
        priority: "high",
      },
    };

    try {
      await admin.messaging().send(message);
      console.log("Notificação enviada para:", fcmToken);
    } catch (e) {
      console.error("Erro ao enviar notificação:", e);
    }

    return null;
  });