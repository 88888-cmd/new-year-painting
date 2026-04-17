<template>
  <div v-if="show" class="video-layer">
    <div class="mask" @touchmove.stop.prevent="() => { }"></div>

    <div class="dialog">
      <video id="video" :src="url" autoplay controls>
      </video>

      <i class="el-icon-close ic-close" @click="close"></i>
    </div>
  </div>
</template>

<script>
export default {
  name: "VideoPreview",
  data: function () {
    return {
      show: false,
      url: ""
    };
  },
  methods: {
    open(url) {
      this.show = true;
      this.url = url;
    },
    close() {
      this.show = false;
      this.url = "";
    },
  }
};
</script>
<style scoped>
.video-layer {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  width: 100%;
  z-index: 5000;
}

.video-layer .mask {
  position: fixed;
  width: 100%;
  height: 100%;
  opacity: 0.5;
  background-color: #000;
}

.dialog {
  width: 960px;
  height: 640px;
  text-align: center;
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: #000;
  box-sizing: border-box;
}

.dialog video {
  width: 100%;
  height: 100%;
}

.ic-close {
  position: absolute;
  right: 10px;
  top: 10px;
  font-size: 25px;
  cursor: pointer;
  z-index: 999;
  color: white;
}
</style>