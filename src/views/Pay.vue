<script setup lang="ts">
import axios from "axios"
import { nextTick, onMounted, ref } from "vue";
import QRCode from 'qrcode';

const isInWx = ref(false)
// 支付费用
const totalFee = ref(1)
const link = 'https://www.example.com'; // 要转换成二维码的链接
const width = 200; // 二维码的宽度
const height = 200; // 二维码的高度

const qrCodeNode = ref();
const isPaySuccess = ref(false)
const payStatus = ref("")

// 初始化
onMounted(() => {
  console.log(`the component is now mounted.`)
  isInWx.value = isWXBrowser()
  if(isInWx.value){
    // 微信环境 直接调用登录
    // window.location.href = "http://www.nisonfuture.cn/api/wechat/auth"
    return
  }
  // 普通浏览器
  // 获取微信支付二维码
  axios.request({
    url: "https://www.nisonfuture.cn/api/pay/gen",
    method: "POST",
    data: {
      "openid":"oPuYn6s3yuFnvmk74ZhYajZyrVCY",
      "productId": 1,
      "isPc": true
    }
  }).then((res: any) => {
    console.log("res", res);
    const { payInfo = {}, orderId } = res.data
    const { code_url } = payInfo
    nextTick(() => {
      console.log("qrCodeNode", qrCodeNode.value, code_url)
      QRCode.toCanvas(qrCodeNode.value, code_url, { width });
      payStatus.value = "等待支付"
      // 轮训接口
      const timer = setInterval(() => {
        axios.request({
          url: "https://www.nisonfuture.cn/api/pay/check",
          method: "POST",
          data: {
            orderId
          }
        }).then(res => {
          // 如果订单状态为2 则支付成功 
          if(res.data?.orderInfo.status == 2){
            payStatus.value = "支付成功"
            clearInterval(timer)
          }
        })
      }, 2000)
    })
  })
})
/**
 * 点击支付
 */
function handleClickPay() {
  console.log("handleClickPay");
  
  axios.request({
    url: "https://www.nisonfuture.cn/api/pay/gen",
    method: "POST",
    data: {
      "openid":"oPuYn6s3yuFnvmk74ZhYajZyrVCY",
      "totalFee": 1,
      "attach": "optional",
      "isPc": false
    }
  }).then((res: any) => {
    console.log("res", res);
    const {appId, timeStamp, nonceStr, package: packageStr, signType, paySign} = res.data?.data || {}
    if(!paySign){
      return
    }
    WeixinJSBridge.invoke(
      'getBrandWCPayRequest', {
         "appId": appId,     //公众号ID，由商户传入     
         "timeStamp": timeStamp,         //时间戳，自1970年以来的秒数     
         "nonceStr": nonceStr, //随机串     
         "package": packageStr,     
         "signType": signType,         //微信签名方式：     
         "paySign": paySign //微信签名 
      },
      function(res: any){
        console.log(" WeixinJSBridge.invoke", res);
        if(res.err_msg == "get_brand_wcpay_request:ok" ){
          isPaySuccess.value = true
        // 使用以上方式判断前端返回,微信团队郑重提示：
              //res.err_msg将在用户支付成功后返回ok，但并不保证它绝对可靠。
        } 
   }); 
  })
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
    <div>支付模块</div>
    <div>
        <div v-if="isInWx">
          <!-- 微信内 -->
          <button v-if="!isPaySuccess" @click="handleClickPay">支付</button>
          <div v-else>恭喜支付成功</div>

        </div>
        <div v-else>
          <!-- pc浏览器内 -->
          <canvas ref="qrCodeNode" :width="width" :height="height" />
          <div>请扫码支付</div>
          <div v-if="payStatus">支付状态：{{payStatus}}</div>
        </div>
    </div>
</template>
