export default {
  async fetch() {
    return new Response("Service under maintenance", {
      status: 503,
      headers: { "content-type": "text/plain" },
    });
  },
};
