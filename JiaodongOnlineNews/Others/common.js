/**
 调整图片尺寸，使其宽度可以在一屏内
 **/
function adjustImgSize(){
    var width = 320*0.9;
    $(this).attr({width:width+"px"});
    $(this).wrap("<div style='width:"+width+"px;height:180px;overflow:hidden;position:relative;'></div>");
    var linkId = $(this).closest("p").attr("id");
    if( linkId ){
        $(this).before("<img src='img_set_flag.png'  style='position:absolute;right:0;bottom:0;' />");
    }
}

function clickImageEvent(event) {
	if(this.attributes["src"].nodeValue!="news_head_placeholder.png" && this.attributes["src"].nodeValue!="img_set_flag.png"){
		var index = $.inArray(this,$("img[src!='img_set_flag.png']"));
		var linkId = $(this).closest("p").attr("id");
		if( linkId ){
            window.newsDetail.redirectImage(linkId);
		}else{
			window.showimage.showimage(index ==-1?0:index);
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
		alert(111);
	}	
}