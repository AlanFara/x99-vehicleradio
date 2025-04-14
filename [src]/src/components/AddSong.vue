<template>
    <div class="modal">
        <div class="header">
            <span>
                Add Song
            </span>
            <button class="close" @click="closeModal">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="input">
            <v-text-field label="Youtube URL" variant="underlined" v-model="input" placeholder="https://www.youtube.com/watch?v=..."></v-text-field>
            <!-- <input type="text" v-model="input" placeholder="https://www.youtube.com/watch?v=..."> -->
        </div>
        <v-btn class="button" @click="playSong" theme="dark">
            Add
        </v-btn>
        <span v-if="progress">
            {{ progress }}
        </span>
    </div>
</template>
 
<script>
import { mapState } from 'vuex'

export default {
    data: () => ({
        player: null,
        input: "",
    }),
    computed: {
        ...mapState({
            displayAddSong: state => state.displayAddSong,
            displayPlaylist: state => state.displayPlaylist,
            modal: state => state.playlist,
            AudioContext: state => state.AudioContext,
            progress: state => state.progress,
        })
    },

    methods: {
        playSong() {
            this.$store.dispatch("addSongToPlaylist", { url: this.input, ref: this.$parent.$refs.audioPlayer })
        },

        onPlayerReady(event) {
            this.$store.dispatch("onPlayerReady")
            event.target.playVideo();
        },

        closeModal() {
            this.$store.dispatch("displayAddSong", false)
        }
    },

    mounted() {
        this.$nextTick(() => {
            this.$store.dispatch("displayPlaylist", false)
            
            setTimeout(() => {
                this.input = "https://music.youtube.com/watch?v=uEwP4gztxWE&list=RDAMVMU9x0dqEOW7Y" // https://www.youtube.com/watch?v=WJlz8OhRjsY
            }, 100);
        })
    }
}
</script>
 
<style scoped lang="scss">
.header {
    display: flex;
    align-items: center;

    span {
        font-weight: 600;
        font-size: 1.8rem;
    }

    .close {
        font-size: 1.4rem;
        width: 3rem;
        margin-left: auto;
        text-align: center;
        height: 3rem;
        line-height: 3rem;
    }
}

.modal {
    background: rgb(51, 51, 82);
    color: white;
    position: absolute;
    inset: 0;
    margin: auto;
    height: 13rem;
    width: 50rem;
    border-radius: 0.4rem;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    padding: 1rem;

    .modal-list {
        overflow: auto;

        .modal-item {
            text-align: left;
            height: 2.5rem;
            padding-inline: 1rem;
            width: -webkit-fill-available;

            background: rgba(92, 92, 138, 0.384);

            &:nth-of-type(2n) {
                background: transparent;
            }

            border-bottom: 1px solid rgba(255, 255, 255, 0.13);

            &:last-child {
                border: none;
            }
        }
    }
}
</style>