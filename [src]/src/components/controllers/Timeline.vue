<template>
    <div class="timeline">
        <span class="time">
            {{ startTime }}
        </span>
        <Slider :end="duration" v-model="sliderValue" @mouseup="seekTo" @mousedown="stopPlaying" />
        <span class="time">
            {{ endTime }}
        </span>
    </div>
</template>

<script>
import Slider from '../Slider.vue';
import { mapState, mapGetters } from 'vuex'

export default {
    data: () => ({
        sliderValue: 0
    }),
    components: {
        Slider
    },
    computed: {
        startTime() {
            return this.formatTime(this.currentTime)
        },
        endTime() {
            return this.formatTime(this.duration)
        },
        currentTime() {
            return this.playerRadio.currentTime
        },
        duration() {
            return this.playerRadio.duration
        },

        ...mapGetters([
            'playerRadio'
        ]),
    },
    methods: {
        formatTime(_time) {
            const time = _time
            var minute = Math.floor(time / 60)
            var second = Math.floor(time % 60)

            if (minute <= 9) minute = "0" + minute
            if (second <= 9) second = "0" + second

            return `${minute}:${second}`
        },
        seekTo(time) {
            this.$nextTick(() => {
                this.$store.dispatch("syncSeekTo", {time})
                this.$store.dispatch("togglePause", {play: true})
            })
        },
        stopPlaying() {
            this.$store.dispatch("togglePause", {play: false})
        },

    },
    mounted() {
        this.$nextTick(() => {
            this.sliderValue = this.currentTime
        })
    },
    watch: {
        // sliderValue() {
        //     this.$store.dispatch("seekTo", this.sliderValue)
        // },
        currentTime() {
            this.sliderValue = this.currentTime
        }
    }
}
</script>

<style lang="scss" scoped>
.timeline {
    display: flex;
    align-items: center;
    // gap: 1rem;
    margin: 0.2rem;

    .time {
        width: 5rem;
        text-align: center;
        font-size: 0.9rem;
    }
}
</style>