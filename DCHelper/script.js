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
    Block: "block",
    AddButton: "add_button",
    GetImage: "get_image"
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
    var type = received.type;
    
    if(type == MessageType.AutoImage){
        var args = received.args;
        
        setTimeout(function(){
            var _gID = document.getElementById("id").value;
            var _rKey = document.getElementById("r_key").value;
            
            var data = args.data;
            var fileName = args.fileName;
            
            var fObj = new FormData();
            fObj.append("r_key",_rKey);
            fObj.append("files[]", b64toBlob(data), fileName);
            
            request(URL_UPLOAD_IMG+_gID, fObj, autoImageProc);
        }, 500);
    
    }else if(type == MessageType.Block){
        var blockers = received.args;
        
        removeBlockedContent(blockers);
    }else if(type == MessageType.AddButton){
        var liObj = document.createElement("li");
        liObj.setAttribute("class", "tx-list");
        liObj.style.zIndex = 4;
        liObj.style.marginTop = "1.45px";
        
        var aObj = document.createElement("a");
        aObj.setAttribute("id", "btnAImage");
        aObj.text = "고정이미지추가"
        aObj.style.verticalAlign = "middle";
        liObj.appendChild(aObj);
        
        var sideBarObj = document.getElementsByClassName("tx-bar-left")[0];
        
        sideBarObj.appendChild(liObj);
        
        document.getElementById("btnAImage").addEventListener("click", function(){
              safari.extension.dispatchMessage(MessageType.GetImage);
        })
    }
}

function removeBlockedContent(blockers){
    var blocked = blockers.split('|');
    
    if(currentPage == Page.View){
        
        [].forEach.call(document.getElementsByClassName("gallery_re_btn"), function(el){
            el.style.display = "none";
        });
       
        var injectScript = document.createElement("script");
        injectScript.text = "$(document).ready(function(){ setTimeout(function(){ getCommentList(0); },1000); Pager = { pageIndexChanged: function(selectedPage){ getCommentList(++_currentPage); } } }); function getCommentList(page){ var _comment_num=_totalItemCount, gall_id=$.getURLParam('id'), vr_no=$.getURLParam('vr'), gall_no=$.getURLParam('no'), csrf_token=get_cookie('ci_c'); $.ajax({url: '/comment/view', method:'POST', data: { ci_t:csrf_token, id: gall_id, no:gall_no, comment_page:page, vr: vr_no}, success: function(data){ $('#comment_list').html(data); clipinit(); var blocklist='"+blockers+"'.split('|'); $('#comment_list').find('.user_layer').each(function(){ if(blocklist.includes($(this).attr('user_name'))){ $(this).parent().hide(); } }) } }) }";
        document.body.appendChild(injectScript);
    }
    
    [].forEach.call(document.getElementsByClassName("user_layer"), function(el){
        var nickName = el.getAttribute("user_name");
                    
        if(blocked.includes(nickName)){
            el.parentElement.style.display = "none";
        }
    });
}

var autoImageProc = function(data){
    var root = data.files[0];
    
    var uploadedInfo = {
        'imageurl': root.url,
        'filename': root.name,
        'filesize': root.size,
        'imagealign': 'L',
        'originalurl': root.url,
        'thumburl': root.url,
        'file_temp_no':root.file_temp_no
    }
    
    var injectScript = document.createElement("script");
    injectScript.text = "Editor.getSidebar().getAttacher('image').attachHandler("+JSON.stringify(uploadedInfo)+");";
    document.body.appendChild(injectScript);
    
    var iframeBody = document.getElementById("tx_canvas_wysiwyg").contentDocument.getElementsByTagName("body")[0];
    var autoImageObj = iframeBody.getElementsByClassName("txc-image")[0];
    iframeBody.innerHTML = "";
    
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
