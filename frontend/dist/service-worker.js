self.addEventListener("install", (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open("sigma-cache").then((cache) => {
      return cache.addAll(["/", "/index.html", "/elm.js"]);
    })
  );
});

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
