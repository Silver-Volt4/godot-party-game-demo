<script>
    import { onMount } from "svelte";
    import getUrl from "./lib/WebSocketConnector";

    let url;
    let ws;

    let input;

    onMount(async () => {
        url = await getUrl();
        ws = new WebSocket(url);
    })
    
    function send() {
        ws.send(JSON.stringify({
            message: input
        }))
        input = "";
    }
</script>

<main>
   <h1>Godot Party Game Demo</h1>
   <input bind:value={input}>
   <button on:click={send}>send</button>
</main>

<style>
</style>
