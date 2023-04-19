<script setup lang="ts">
import axios from "axios"
import { onMounted, ref } from "vue";
// 二维码
const qrCodeSrc = ref("")
const myToken = ref("")
// 上次轮训的timer
let preTimer 
// 初始化
onMounted(() => {
  console.log(`the component is now mounted.`)
  if(isWXBrowser()){
    // 微信环境 直接调用登录
    window.location.href = "http://www.nisonfuture.cn/api/wechat/auth"
    return
  }
  // 普通浏览器
  // 获取微信二维码
  axios.request({
    url: "http://www.nisonfuture.cn/api/oauth/qrcode"
  }).then((res: any) => {
    console.log("res", res);
    const { qrcodeUrl, scene } = res.data
    qrCodeSrc.value = qrcodeUrl
    startMonitorLogin(scene)
  })
})

// 开始轮训是否登录成功
function startMonitorLogin(scene: string) {
    if(!scene){
        console.log("没有scene");
        return
    }
    // 定时
    const timer = setInterval(() => {
        axios.request({
            url: `http://www.nisonfuture.cn/api/oauth/scene?scene=${scene}`,
        }).then((res) => {
            // 获取到重定向页面路径
            const { token } = res.data
            console.log("scene data", res.data)
            if(token){
                // 有结果 则跳转页面
                clearInterval(timer)
                myToken.value = token
                // window.location.href = redirectUrl
            }
        })
    }, 5000)
}

//判断是否是微信内置的浏览器
function isWXBrowser() {
  return (
    String(navigator.userAgent.toLowerCase().match(/MicroMessenger/i)) ===
    "micromessenger"
  );
}
</script>

<template>
    <div>我是页面</div>
    <div>
        <img v-if="qrCodeSrc" :src="qrCodeSrc" style="width: 100px; height: 100px;"/>
        <div>我的token：{{ myToken }}</div>
    </div>
</template>
