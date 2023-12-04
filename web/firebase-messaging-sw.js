importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyD1F9mJKoFyn04KKqhU9gj5zP8zK5VVwNk",
    authDomain: "linen-waters-391213.firebaseapp.com",
    projectId: "linen-waters-391213",
    storageBucket: "linen-waters-391213.appspot.com",
    messagingSenderId: "515615342869",
    appId: "1:515615342869:web:d34aaf1d7a06704e03691c",
    measurementId: "G-Z73PL2NJ3C"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});