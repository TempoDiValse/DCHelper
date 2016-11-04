const PREFIX = "http://gall.dcinside.com/";
const MINOR_PREFIX = "mgallery/";
const BOARD_PREFIX = "board/";

const URL_UPLOAD_IMG = "//upimg.dcinside.com/upimg_file.php?id=";

var Page = {
    List : "lists",
    Write : "write",
    View : "view"
}

var MessageType = {
    AutoImage : "auto_image",
    Block: "block"
};

var received;
var currentPage = "";

safari.self.addEventListener("message", fromExtension);

document.addEventListener("DOMContentLoaded", function(event) {
      var url = document.location.href;
    
      if(url.startsWith(PREFIX)) {
          var dcurl = url.substring(PREFIX.length);
              
          if(dcurl.startsWith(MINOR_PREFIX)){
              dcurl = dcurl.substring(MINOR_PREFIX.length);
          }
          
          dcurl = dcurl.substring(BOARD_PREFIX.length);
          
          if(dcurl.startsWith(Page.List)){
              currentPage = Page.List;
          }else if(dcurl.startsWith(Page.Write)){
              currentPage = Page.Write;
          }else if(dcurl.startsWith(Page.View)){
              currentPage = Page.View;
          }else{
              currentPage = "";
          }
                          
          if(currentPage != ""){
              safari.extension.dispatchMessage(currentPage);
          }
      }
});

function fromExtension(e){
    received = e.message;
    
    if(received.type == MessageType.AutoImage){
        var args = received.args;
        
        var _gID = document.getElementById("id").value;
        var _rKey = document.getElementById("r_key").value;
        var data = args.data;
        var fileName = args.fileName;
        
        var fObj = new FormData();
        fObj.append("r_key",_rKey);
        fObj.append("files[]", b64toBlob(data), fileName);
        
        setTimeout(function(){
            request(URL_UPLOAD_IMG+id, fObj, autoImageProc);
        },500);
    }else if(received.type == MessageType.Block){
        var blockers = received.args;
        removeBlockedContent(blockers);
    }
}


function removeBlockedContent(blockers){
    var blocked = blockers.split('|');
    
    if(currentPage == Page.View){
        
        [].forEach.call(document.getElementsByClassName("gallery_re_btn"), function(el){
            el.style.display = "none";
        });
               
        var injectScript = document.createElement("script");
        injectScript.text = "var htmlData='';$(document).ready(function(){ var pageCount=Math.ceil(parseInt($('#comment_num').val())/40); for(var i=pageCount; i>0; i--){ getCommentList(i); }});function getCommentList(page){ var _comment_num=parseInt($('#comment_num').val()), gall_id=$.getURLParam('id'), vr_no=$.getURLParam('vr'), gall_no=$.getURLParam('no'), csrf_token=get_cookie('ci_c'); $.post('/comment/view', { ci_t:csrf_token, id: gall_id, no:gall_no, comment_page:page, vr: vr_no}, function(data){ htmlData += data; if(page == 1){ $('#comment_list').html(htmlData); clipinit(); $('#pager').hide(); }})}";
        document.body.appendChild(injectScript);
        
        setTimeout(function(){
                   [].forEach.call(document.getElementsByClassName("user_layer"), function(el){
                       var nickName = el.getAttribute("user_name");
                       
                       if(blocked.includes(nickName)){
                       el.parentElement.style.display = "none";
                       }
                    });
        }, 1000);
    }else{
        [].forEach.call(document.getElementsByClassName("user_layer"), function(el){
            var nickName = el.getAttribute("user_name");
                        
            if(blocked.includes(nickName)){
                el.parentElement.style.display = "none";
            }
        });
    }
}

var autoImageProc = function(data){
    var root = data.files[0];
    
    var uploadedInfo = {
        'imageurl': (root.width >= 850) ? root.web__url : root.url,
        'filename': root.name,
        'filesize': root.size,
        'imagealign': 'L',
        'originalurl': root.url,
        'thumburl': root.s_url,
        'file_temp_no':root.file_temp_no
    }
    
    var injectScript = document.createElement("script");
    injectScript.text = "Editor.getSidebar().getAttacher('image').attachHandler("+JSON.stringify(uploadedInfo)+")";
    document.body.appendChild(injectScript);
    
    var iframeBody = document.getElementById("tx_canvas_wysiwyg").contentDocument.getElementsByTagName("body")[0];
    var autoImageObj = iframeBody.getElementsByClassName("txc-image")[0];
    autoImageObj.setAttribute("width", received.args.width);
    autoImageObj.setAttribute("height", received.args.height);
    
    document.getElementById("upload_status").value = 'Y';
}

function request(url, dataObj, callback){
    var xhr = new XMLHttpRequest();
    
    xhr.open("POST", url, true);
    xhr.onreadystatechange = function(){
        if(xhr.readyState == XMLHttpRequest.DONE && xhr.status === 200){
            var response = JSON.parse(xhr.responseText);
            
            callback(response);
        }
    }
    
    xhr.send(dataObj);
}

function b64toBlob(b64Data, contentType, sliceSize) {
    contentType = contentType || '';
    sliceSize = sliceSize || 512;
    
    var byteCharacters = atob(b64Data);
    var byteArrays = [];
    
    for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        var slice = byteCharacters.slice(offset, offset + sliceSize);
        
        var byteNumbers = new Array(slice.length);
        for (var i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }
        
        var byteArray = new Uint8Array(byteNumbers);
        
        byteArrays.push(byteArray);
    }
    
    var blob = new Blob(byteArrays, {type: contentType});
    return blob;
}
