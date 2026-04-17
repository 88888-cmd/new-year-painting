<template>
  <div class="app-container">
    <div class="card-wrapper">
      <div class="card-wrapper-body">
          <div class="title">年画后台系统</div>
          <div class="info">Welcome To PaintingApp AdminSystem</div>
          <div class="content">
            <p>ICP：123456789</p>
          </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {

}
</script>

<style scoped>
.app-container {
  min-height: calc(100vh - 50px);
  background-color: rgb(240, 242, 245);
}

.card-wrapper {
  width: 100%;
  min-height: 148px;
  border-radius: 0;
  position: relative;
  padding: 10px 20px 13px;
  background-color: #fff;
  color: #333;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

.card-wrapper-body {
  padding: 0 15px;
  width: 100%;
  margin-top: 3.2rem;
}

.card-wrapper:after,
.card-wrapper:before {
  content: " ";
  display: table;
}
.card-wrapper:after {
  clear: both;
}

.title {
  font-size: 40px;
  font-weight: bold;
  color: #838fa1;
  text-align: center;
}

.content {
  padding: 10px 0;
  margin-top: 20px;
  margin-bottom: 20px;
  font-size: 16px;
  text-align: center;
  color: #96a2b4;
}

.info {
  line-height: 30px;
  font-size: 21px;
  margin-top: 20px;
  text-align: center;
  color: #dce2ec;
}
</style>
