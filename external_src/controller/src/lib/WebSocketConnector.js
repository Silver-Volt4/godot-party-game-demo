async function getUrl() {
    let url = new URL(window.location.toString());
    if (import.meta.env.DEV) {
        url.port = "12003";
    }
    url.pathname = "/game";
    let f = await fetch(url.toString());
    let new_port = await f.text();
    url.port = new_port;
    url.protocol = "ws";
    url.pathname = "";
    return url;
}

export default getUrl;