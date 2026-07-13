// Minimal service worker for CallFlow.
// This exists so the app is installable as a PWA on Android/Chrome.
// It deliberately does NOT cache API/data responses, so Matt always sees
// live data from Supabase — it just needs to exist and handle fetch.

self.addEventListener("install", (event) => {
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener("fetch", (event) => {
  // Always go to the network. No caching of dynamic data.
  event.respondWith(fetch(event.request));
});
