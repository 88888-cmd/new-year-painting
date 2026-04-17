<template>
  <div>
    <el-card class="form-container" shadow="never">
      <aside style="margin-bottom: 20px">图文内容</aside>
      <div id="editor—wrapper">
        <div id="toolbar-container"><!-- 工具栏 --></div>
        <div id="editor-container"><!-- 编辑器 --></div>
      </div>

      <div style="text-align: center; margin-top: 20px">
        <el-button type="primary" size="medium" @click="clickSave">保存</el-button>
      </div>
    </el-card>
  </div>
</template>

<script>
import { uploadImg } from '@/api/file';

let editor = null;
import { createToolbar, createEditor } from '@wangeditor/editor';
import "@wangeditor/editor/dist/css/style.css";

import { getArticleContent, setArticleContent } from "@/api/banner";
export default {
  data() {
    return {
    }
  },
  created() {
  },
  mounted() {
    let that = this;
    editor = createEditor({
      selector: '#editor-container',
      config: {
        placeholder: '请输入...',
        autoFocus: false,
        customPaste: (editor, event) => {
          const text = event.clipboardData.getData('text/plain')
          editor.insertText(text)
          event.preventDefault()
          return false
        },
        MENU_CONF: {
          'uploadImage': {
            // maxFileSize: 5 * 1024 * 1024, // 5M
            // maxNumberOfFiles: 1,
            // allowedFileTypes: ["image/*"],
            customUpload(file, insertFn) {
              const isJpgPng = file.type === "image/jpeg" || file.type === "image/png";
              const isLt5M = file.size / 1024 / 1024 < 5;
              if (!isJpgPng) {
                that.$message.error("上传图片只能是 JPG/PNG 格式");
                return;
              }
              if (!isLt5M) {
                that.$message.error("图片大小不能超过5MB");
                return;
              }

              let fetchForm = new FormData();
              fetchForm.append('file', file);
              uploadImg(fetchForm).then(response => {
                insertFn(response.data.file_url)
              })
            }
          },
          'fontSize': {
            fontSizeList: [
              '12px',
              '14px',
              '16px',
              '18px',
              '20px',
              '24px',
              '28px',
              '32px',
              '36px',
              '40px',
            ]
          }
        },
        hoverbarKeys: {
          'image': {
            menuKeys: [
              'imageWidth30',
              'imageWidth50',
              'imageWidth100',
              'deleteImage'
            ],
          }
        },
        onCreated: (editor) => {
          this.fetchData();
        }
      },
      mode: 'simple'
    });
    const toolbar = createToolbar({
      editor,
      selector: '#toolbar-container',
      config: {
        toolbarKeys: ['fontSize', 'bold', 'underline', 'italic', 'through', '|', 'color', 'bgColor', '|', 'uploadImage', '|', 'clearStyle']
      },
      mode: 'simple'
    });


    // console.log(toolbar.getConfig().toolbarKeys)
    that.$once('hook:beforeDestroy', () => {
      if (editor != null) {
        editor.destroy();
        editor = null;
      }
    });
  },
  methods: {
    fetchData() {
      getArticleContent(this.$route.params.id).then((response) => {
        if (editor != null) {
          editor.setHtml(response.data);
        }
      });
    },
    clickSave() {
      let that = this;
      setArticleContent(this.$route.params.id, editor.getHtml()).then(response => {
        this.$message.success("保存成功");
      });
    }
  }
}
</script>

<style scoped>
#editor—wrapper {
  border: 1px solid #ccc;
  z-index: 100;
}

#toolbar-container {
  border-bottom: 1px solid #ccc;
}

#editor-container {
  height: 500px;
}
</style>