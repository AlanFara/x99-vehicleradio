<template>
   <div class="radio">
      <SoundName />
      <ControlButtons />
      <Timeline />
   </div>
</template>

<script>
import Timeline from './controllers/Timeline.vue';
import ControlButtons from './controllers/ControlButtons.vue';
import SoundName from './controllers/SoundName.vue';

export default {
   components: {
      Timeline,
      ControlButtons,
      SoundName,
   }
}
</script>

<style scoped lang="scss">
.radio {
   color: white;
   flex: 1;
   display: flex;
   gap: 0.6rem;
   flex-direction: column;
   justify-content: center;
   margin-block: 1rem;

   audio {
      display: none;
   }
}
</style>