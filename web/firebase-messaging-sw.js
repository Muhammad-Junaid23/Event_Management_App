// web/firebase-messaging-sw.js
importScripts(
  "https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js",
);

firebase.initializeApp({
  apiKey: "AIzaSyA4lTXuzY3MYNs3ArsUpNveyunZsSgu4fY",
  authDomain: "event-management-app-147d4.firebaseapp.com",
  projectId: "event-management-app-147d4",
  storageBucket: "event-management-app-147d4.firebasestorage.app",
  messagingSenderId: "909586382430",
  appId: "1:909586382430:web:7132f78fc73cd36e94becf",
});

const messaging = firebase.messaging();

// Ensures the service worker activates immediately.
self.addEventListener("install", () => {
  self.skipWaiting();
});
self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim());
});

messaging.onBackgroundMessage((payload) => {
  console.log(
    "[firebase-messaging-sw.js] Received background message ",
    payload,
  );

  const notificationTitle =
    payload.notification?.title || "Event Management System";
  const notificationOptions = {
    body: payload.notification?.body || "",
    icon: payload.notification?.icon || "/icons/Icon-192.png",
    data: {
      route: payload.data?.route || "/",
    },
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handles the notification click event.
self.addEventListener("notificationclick", (event) => {
  event.notification.close(); // Close the notification.

  const route = event.notification.data?.route || "/";

  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clientList) => {
        for (const client of clientList) {
          if (client.url.includes(self.location.origin) && "focus" in client) {
            client.focus();
            // Use postMessage to notify the Flutter app, or navigate directly.
            // Navigating directly is simpler.
            client.navigate("/#" + route);
            return;
          }
        }
        if (clients.openWindow) {
          return clients.openWindow("/#" + route);
        }
      }),
  );
});
