<template>
  <div class="login-container">
    <el-form ref="loginForm" :model="loginForm" :rules="loginRules" class="login-form" auto-complete="on"
      label-position="left">
      <div class="title-container">
        <h3 class="title">年画后台系统</h3>
      </div>

      <el-form-item prop="username">
        <el-input ref="username" v-model="loginForm.username" placeholder="用户名" name="username" type="text" tabindex="1"
          auto-complete="on" maxlength="20" />
      </el-form-item>

      <el-form-item prop="password">
        <el-input ref="password" v-model="loginForm.password" placeholder="密码" name="password" type="password"
          tabindex="2" auto-complete="on" maxlength="20" @keyup.enter.native="handleLogin" show-password />
      </el-form-item>

      <el-button :loading="loading" type="primary" style="width: 100%; margin-bottom: 30px"
        @click.native.prevent="handleLogin">安全登录</el-button>
    </el-form>
  </div>
</template>

<script>
export default {
  name: "Login",
  data() {
    return {
      loginForm: {
        username: "",
        password: "",
      },
      loginRules: {
        username: [
          { required: true, trigger: "blur", message: "请输入用户名" },
        ],
        password: [{ required: true, trigger: "blur", message: "请输入密码" }],
      },
      loading: false
    };
  },
  methods: {
    handleLogin() {
      let that = this;

      that.$refs.loginForm.validate((valid) => {
        if (valid) {
          that.loading = true;
          that.$store
            .dispatch("user/login", that.loginForm)
            .then(() => {
              that.$router.push({ path: '/' });
              that.loading = false;
            })
            .catch(() => {
              that.loading = false;
            });
        } else {
          return false;
        }
      });
    },
  },
};
</script>

<style>
@supports (-webkit-mask: none) and (not (cater-color: #fff)) {
  .login-container .el-input input {
    color: #fff;
  }
}

.login-container .el-input {
  display: inline-block;
  height: 47px;
  width: 100%;
}

.login-container .el-input input {
  background: transparent;
  border: 0px;
  -webkit-appearance: none;
  border-radius: 0px;
  padding: 12px 5px 12px 15px;
  color: #fff;
  width: 100%;
  height: 47px;
  caret-color: #fff;
}

.login-container .el-input input:-webkit-autofill {
  box-shadow: 0 0 0px 1000px #283443 inset !important;
  -webkit-text-fill-color: #fff !important;
}

.login-container .el-input input[type="password"]::-ms-reveal {
  display: none;
}

.login-container .el-form-item {
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(0, 0, 0, 0.1);
  border-radius: 5px;
  color: #454545;
}
</style>

<style scoped>
.login-container {
  min-height: 100%;
  width: 100%;
  background-color: #2d3a4b;
  overflow: hidden;
}

.login-container .login-form {
  position: relative;
  width: 520px;
  max-width: 100%;
  padding: 160px 35px 0;
  margin: 0 auto;
  overflow: hidden;
}

.login-container .title-container {
  position: relative;
}

.login-container .title-container .title {
  font-size: 26px;
  color: #eee;
  margin: 0px auto 40px auto;
  text-align: center;
  font-weight: bold;
}
</style>
