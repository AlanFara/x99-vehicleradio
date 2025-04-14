<template>
    <v-slider :max="end" v-model="input" :direction="orient" ref="slider" @update:modelValue="updateValue" @end="change" color="rgb(128 223 58)" hide-details></v-slider>
    <!-- <input type="range" id="slider" min="0" :max="end" :value="input" :orient="orient" ref="slider" @input="updateValue" @change="change" @mousedown="mouseDown"> -->
</template>

<script>
export default {
    emits: ["update:modelValue", "change", "mousedown", "mouseup", "input"],
    data: () => ({
        sliderProps: {
            fill: "rgb(128 223 58)",
            background: "rgba(255, 255, 255, 0.314)",
        },
        input: 0
    }),
    props: {
        start: {
            default: 0,
            type: Number
        },
        end: {
            default: 100,
            type: Number
        },
        modelValue: {
            type: Number,
            default: 0,
        },
        orient: {
            type: String,
        },
    },
    beforeMount() {
        this.input = this.modelValue
    },
    mounted() {
        document.addEventListener("mousedown", this.checkMouseEvents)
        document.addEventListener("mouseup", this.checkMouseEvents)
    },
    watch: {
        input() {
            this.applyFill(this.$refs.slider)
        },
        modelValue() {
            this.input = this.modelValue
        },
    },
    methods: {
        async applyFill(slider) {
            // await slider
            // if (!slider) slider = this.$refs.slider
            // const percentage = (100 * (slider.value - slider.min)) / (slider.max - slider.min);
            // const bg = `linear-gradient(90deg, ${this.sliderProps.fill} ${percentage}%, ${this.sliderProps.background} ${percentage +
            //     0.1}%)`;
            // slider.style.background = bg;
        },
        updateValue(value) {
            this.input = value || this.input || 0
            this.$emit("update:modelValue", this.input);
            this.$emit("input", this.input);
        },
        change(event) {
            this.$emit("change", this.input);
        },
        mouseDown(event) {
            this.$emit("mousedown", this.input);
        },
        checkMouseEvents(event) {
            if (this.$refs.slider?.$el && this.$refs.slider.$el.contains(event.target)) {
                if (event.type == "mousedown") {
                    this.$emit("mousedown", this.input);
                } else if (event.type == "mouseup") {
                    this.$emit("mouseup", this.input);
                }
            }
        }
    },
}
</script>

<style scoped lang="scss">
#slider {
    -webkit-appearance: none;
    width: -webkit-fill-available;

    height: 0.4rem;
    border-radius: 5px;
    background: rgba(255, 255, 255, 0.314);
    outline: none;
    padding: 0;
    margin: 0;
    cursor: pointer;

    // Range Handle
    &::-webkit-slider-thumb {
        -webkit-appearance: none;
        width: 0.8rem;
        height: 0.8rem;
        border-radius: 50%;
        background: rgb(255, 255, 255);
        cursor: pointer;
        transition: all 0.15s ease-in-out;

        &:hover {
            background: rgb(212, 212, 212);
            transform: scale(1.2);
        }
    }

    &::-moz-range-thumb {
        width: 0.8rem;
        height: 0.8rem;
        border: 0;
        border-radius: 50%;
        background: rgb(255, 255, 255);
        cursor: pointer;
        transition: background 0.15s ease-in-out;

        &:hover {
            background: rgb(212, 212, 212);
        }
    }

}

.v-slider:deep(.v-input__control) {
    min-height: 1rem !important;
}
</style>