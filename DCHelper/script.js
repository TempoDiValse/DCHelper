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
    GetImage: "get_image",
    Download: "download_file",
    SendURLToApp: "send_urls"
};

var received;
var currentPage = "";
var gType = "main";

var _href = document.location.href;
safari.self.addEventListener("message", fromExtension, true);

document.addEventListener("DOMContentLoaded", function(event) {
    var url = document.location.href;
    
    if(url.startsWith(PREFIX)) {
                          
        var dcurl = url.substring(PREFIX.length);

        if(dcurl.startsWith(MINOR_PREFIX)){
            gType = "minor";
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
    if(currentPage == "") return; // 현재 페이지가 없는 이벤트는 실행할 수 없도록 방지.
                                  // (한 페이지 내에서 페이지 호출이 여러번 있으면 이벤트가 중복으로 등록되는 이상한 이슈가 있음)
    received = e.message;
    var type = received.type;
    
    console.log("/*------------*/");
    console.log("Page: "+currentPage);
    console.log("Type: "+type);
    console.log("/*------------*/");
    
    if(type == MessageType.AutoImage){
        var args = received.args;
        
        var _gID = document.getElementById("id").value;
        var _rKey = document.getElementById("r_key").value;
       
        var data = args.data;
        var fileName = args.fileName;
       
        var fObj = new FormData();
        fObj.append("r_key",_rKey);
        fObj.append("files[]", b64toBlob(data), fileName);
       
        request(URL_UPLOAD_IMG+_gID, fObj, autoImageProc);
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
        
        var liObj2 = document.createElement("li");
        liObj2.setAttribute("class", "tx-list");
        liObj2.style.zIndex = 4;
        liObj2.style.marginTop = "5.3px";
        
        var progObj = document.createElement("div");
        progObj.style.position = "relative";
        progObj.style.width = "100px";
        progObj.style.height = "15px";
        progObj.style.backgroundColor = "#333";
        progObj.style.borderRadius = "7px";
        progObj.style.overflow = "hidden";
        
        var progObj2 = document.createElement("div");
        progObj2.setAttribute("id", "progress-bar");
        progObj2.style.position = "relative";
        progObj2.style.width = "0px";
        progObj2.style.height = "15px";
        progObj2.style.backgroundColor = "#A63F38";
        progObj.appendChild(progObj2);
        liObj2.appendChild(progObj);
        
        var sideBarObj = document.getElementsByClassName("tx-bar-left")[0];
        
        sideBarObj.appendChild(liObj);
        sideBarObj.appendChild(liObj2);
        
        document.getElementById("btnAImage").addEventListener("click", function(){
            safari.extension.dispatchMessage(MessageType.GetImage);
        })
    }else if(type == MessageType.Download){
        var refs = document.querySelectorAll(".appending_file .icon_pic");
        var arrs = [];
        
        if(refs.length > 0){
            [].forEach.call(refs, function(el){
                var aObj = el.children[0];
                
                var url = aObj.href.replace("image.dcinside.com/download.php","dcimg2.dcinside.com/viewimage.php");
                var file = {
                    name : aObj.text,
                    url : url
                }
                
                arrs.push(file);
            });
            
            safari.extension.dispatchMessage(MessageType.SendURLToApp, { "href":_href, "urls": arrs });
        }else{
            console.log("nothing to download");
        }
    }
}

function removeBlockedContent(blockers){
    var blocked = blockers.split('|');
    
    if(currentPage == Page.View){
        
        [].forEach.call(document.getElementsByClassName("gallery_re_btn"), function(el){
            el.style.display = "none";
        });
        
        var injectScript = document.createElement("script");
        injectScript.text = "$(document).ready(function(){ setTimeout(function(){ getCommentList(0); },1000); Pager = { pageIndexChanged: function(selectedPage){ getCommentList(++_currentPage); } } }); function getCommentList(page){ var _comment_num=_totalItemCount, gall_id=$.getURLParam('id'), vr_no=$.getURLParam('vr'), gall_no=$.getURLParam('no'), csrf_token=get_cookie('ci_c'); $.ajax({url: '"+((gType == "minor")?"/mgallery":"")+"/comment/view', method:'POST', data: { ci_t:csrf_token, id: gall_id, no:gall_no, comment_page:page, vr: vr_no}, success: function(data){ $('#comment_list').html(data); clipinit(); var blocklist='"+blockers+"'.split('|'); $('#comment_list').find('.user_layer').each(function(){ if(blocklist.includes($(this).attr('user_name'))){ $(this).parent().hide(); } }) } }) }";
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
    
    alert("사진이 첨부되었습니다.");
    
    document.getElementById("progress-bar").style.width = "0px";
}

function request(url, dataObj, callback){
    var xhr = new XMLHttpRequest();
    
    xhr.upload.onprogress = function(e){
        if(e.lengthComputable){
            var percent = parseInt((e.loaded / e.total) * 100);
            
            var progObj = document.getElementById("progress-bar");
            progObj.style.width = percent+"px";
        }
    }
    
    xhr.onreadystatechange = function(){
        if(xhr.readyState == XMLHttpRequest.DONE && xhr.status === 200){
            var response = JSON.parse(xhr.responseText);
            
            callback(response);
        }
    }
    
    xhr.open("POST", url);
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
