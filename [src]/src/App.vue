<template>
    <v-app>
        <v-main>
            <div class="container">
                <audio ref="audioPlayer" id="audioPlayer" controls></audio>
                <!-- <span class="debug">
                    {{ debugText }}
                </span> -->
                <Playlist v-if="displayPlaylist" />
                <AddSong v-if="displayAddSong" />
                <div class="radio-container" v-if="displayRadio">
                    <Equalizer />
                    <Radio />
                </div>
            </div>
        </v-main>
    </v-app>
</template>

<script>
import Radio from "./components/Radio.vue"
import Playlist from "./components/Playlist.vue";
import AddSong from "./components/AddSong.vue";
import Equalizer from "./components/Equalizer.vue";
import { mapState } from "vuex";

export default {
    components: {
        Radio,
        Playlist,
        AddSong,
        Equalizer
    },

    computed: {
        ...mapState({
            displayRadio: state => state.displayRadio,
            displayPlaylist: state => state.displayPlaylist,
            displayAddSong: state => state.displayAddSong,
            globalRadios: state => state.globalRadios,
        }),
        debugText() {
            // hide base64 data from debug
            var debugRadio = this.globalRadios
            for (let i = 0; i < debugRadio.length; i++) {
                const radio = debugRadio[i];
                
                for (let j = 0; j < radio.playlist.length; j++) {
                    const song = radio.playlist[j];
                    song.base64 = "hidden"
                }
            }
            return JSON.stringify(debugRadio, null, 2)
        }
    },

    mounted() {
        this.$nextTick(() => {
            if (process.env.NODE_ENV != 'production') {
                this.$store.state.displayRadio = true;
            }
        });
    }
}
</script>

<style lang="scss">
@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@100;300;400;500;700&display=swap');
@import url("https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css");

.radio-container {
    min-height: 8rem;
    width: 50rem;
    position: absolute;
    bottom: 3rem;
    left: 0;
    right: 0;
    margin-inline: auto;
    margin-top: auto;
    background: rgb(51, 51, 82);
    border-radius: 0.4rem;
    display: flex;
    // flex-direction: column;
}

#audioPlayer {
    display: none;
}

span.debug {
    white-space: break-spaces;
    color: white;
    font-family: monospace;
    position: absolute;
}
</style>