const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendHabitNotifications = functions.pubsub
    .schedule("every day 08:00")
    .onRun(async (context) => {
      try {
        console.log("Fetching users");
        const usersSnapshot = await admin.firestore()
            .collection("users").get();
        const promises = [];

        usersSnapshot.forEach(async (userDoc) => {
          const userEmail = userDoc.data().email;
          const userId = userDoc.id;

          console.log(`Processing user: ${userEmail}, ${userId}`);
          const habitsQuery = admin.firestore()
              .collection("habits")
              .where("userEmail", "==", userEmail);
          const habitsSnapshot = await habitsQuery.get();

          let message = "Congrats, you do not have any habit today";
          if (!habitsSnapshot.empty) {
            message = "Hey buddy, you have a habit today, please check it";
          }

          const payload = {
            notification: {
              title: "Habit Reminder",
              body: message,
            },
          };

          console.log(`Fetching tokens for user: ${userId}`);
          const userDeviceTokens = admin.firestore()
              .collection("userTokens")
              .doc(userId);
          const tokenDoc = await userDeviceTokens.get();
          if (tokenDoc.exists) {
            const tokens = tokenDoc.data().tokens;
            console.log(`Sending notification to tokens: ${tokens}`);
            promises.push(admin.messaging().sendToDevice(tokens, payload));
          } else {
            console.log(`No tokens found for user: ${userId}`);
          }
        });

        await Promise.all(promises);
        console.log("Notifications sent successfully");
      } catch (error) {
        console.error("Error sending notifications:", error);
      }
    });

exports.triggerSendHabitNotifications = functions.runWith({
  timeoutSeconds: 540,
  memory: "1GB",
}).https.onRequest(async (req, res) => {
  try {
    console.log("Manually triggering sendHabitNotifications");
    await exports.sendHabitNotifications();
    res.send("Notifications sent!");
  } catch (error) {
    console.error("Error triggering notifications:", error);
    res.status(500).send("Internal Server Error");
  }
});
