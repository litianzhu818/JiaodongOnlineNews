/**
 调整图片尺寸，使其宽度可以在一屏内
 **/
function adjustImgSize(){
    var width = 320*0.9;
    $(this).attr({width:width+"px"});
    $(this).wrap("<div style='width:"+width+"px;overflow:scroll;position:relative;'></div>");
    var linkId = $(this).closest("p").attr("id");
    if( linkId ){
        $(this).before("<img src='img_set_flag.png'  style='position:absolute;right:0;bottom:0;' />");
    }
    if($(this).attr("isadv") == "true") {
        $(this).before("<img src='adv.png' isadv='true' style='position:absolute;right:1px;bottom:1px;width:25px;height:25px;' />");
    }
}

function clickImageEvent(event) {
    if($(this).attr("isadv")!="true") {
        if(this.attributes["src"].nodeValue!="news_head_placeholder.png" && this.attributes["src"].nodeValue!="img_set_flag.png"){
            var index = $.inArray(this,$("img[isadv!='true']"));
            var linkId = $(this).closest("p").attr("id");
            
            if( linkId ){
                bridge.callHandler('showImageSet', {'linkId': linkId}, function(response) {
                                   
                                   });
            }else{
                bridge.callHandler('showImageDetail', {'imageId': index}, function(response) {
                                   
                                   });
            }
        }
    } else {
        if($(this).attr("advid")){
            bridge.callHandler('showAdv', {'advid': $(this).attr("advid")}, function(response) {
                              
                              });
        }
	}
	
}

function refreshImg(realURL, localURL) {
	//alert(realURL);
	//alert(localURL);
	var $obj = $("img[realUrl='" + realURL + "']");
	if($obj.attr("src")) {
		$obj.attr("src", localURL);
		$obj.each(adjustImgSize);
	} else {
		//alert(111);
	}	
}