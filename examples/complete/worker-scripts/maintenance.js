export default {
  async fetch(request, env, ctx) {
    return new Response("Service under maintenance", {
      status: 503,
      headers: { "content-type": "text/plain" },
    });
  },
};
