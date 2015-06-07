
var findLiblary = findLiblary || {};


(function (findLiblary){
	var incrementalSearchInterval = 2000;

	function moveSelected(select_elm, updown) {
		var select_box = jQuery(select_elm);
		var options = select_box.children('option');
		var selected_index = options.index(select_box.children('option:selected')[0]);
		if (updown == 'up') {
			if (selected_index <= 0) {
				return false;
			}
			select_box.val(options.eq(selected_index-1).val());
		}
		else if (updown == 'down') {
			if (selected_index >= options.length) {
				return false;
			}
			select_box.val(options.eq(selected_index+1).val());
		}
	}


	findLiblary.setIncrementalSearchAgent = function(selecter) {
		var interval = 100;
		jQuery(selecter).each(function() {
			var target = jQuery(this);
			var old = target.val();
			function getStationList(target, str) {
				if (!str) {
					return;
				}
				var _target = target;
				if (!_target.is(':focus') ){
					return;
				}
				jQuery.getJSON('ajax/station?name='+str, function(json) {
					var text = '';
					if (json.length == 0) {
						return;
					}
					for(var i=0; i<json.length; i++) {
						var station = json[i];
						text += '<option value='+station.code+'>'+station.name+'</option>';
					}
				 	var options = jQuery(text);
				 	var station_select = _target.nextAll('.stationSelectBox').empty().append(options).show().css('display','inline').val(options.eq(0).val());
				 	(function(jq_station_entry, jq_station_select){
				 		jq_station_select.click(function(){
				 			jq_station_entry.val( jq_station_select.children('option:selected').text() );
				 			jq_station_select.hide();
				 			old = jq_station_entry.val();
				 			jq_station_entry.parents('.inputrow').next().find('.stationEntry').focus();
				 		})
				 	})(_target, station_select);
				})
			}
			target.keydown(function(e){
				if (e.keyCode == 13) {
					//Enter
					jQuery(this).nextAll('.stationSelectBox').click();
				}
				else if (e.keyCode == 38) {
					//↑
					moveSelected(jQuery(this).nextAll('.stationSelectBox')[0], 'up');
				}
				else if (e.keyCode == 40) {
					//↓
					moveSelected(jQuery(this).nextAll('.stationSelectBox')[0], 'down');
				}
			});
			function check()
			{
				var v = target.val();
				if (old != v) {
					old = v;
					getStationList(target, v);
				}
				setTimeout(check,incrementalSearchInterval);
			}
			setTimeout(check,incrementalSearchInterval);
		});
	};

	findLiblary.attachSearchRoute = function(selecter) {
		jQuery(selecter).click(function(){
			var stationList = [];
			var entrys = jQuery('.stationEntry')
			entrys.each(function () {
				var val = jQuery(this).val();
				if (val) {
					stationList.push(val);
				}
			})
			var to = stationList.splice(1, 1)[0];
			stationList.push(to);
			var viaList = stationList.join(':');
			jQuery('#search_result').load("/search?viaList=" + viaList, function(){
				findLiblary.attachSelectResult('.routeSelect');
				jQuery('#search_result').animatescroll({scrollSpeed:2000,easing:'easeOutElastic'});
			})
		});
	}

	findLiblary.attachSelectResult = function(selecter) {
		jQuery(selecter).click(function(){
			serializeData = jQuery(this).nextAll('input').val();
			jQuery('#result').load("/result?serializeData=" + serializeData,function(){
				findLiblary.attachAndExecSearchLibrary();
				jQuery('#result').animatescroll({scrollSpeed:2000,easing:'easeOutBounce'});
			})
		})
	}

	findLiblary.attachAndExecSearchLibrary = function() {
		jQuery('.station-data').each(function(){
			stationData = jQuery(this);
			geocode = stationData.find('.geocode').val();
			primary = stationData.find('.primary').val();
			if (primary == 'true') {
				(function(ex_stationData, ex_geocode) {
					searchLibrary(ex_stationData, ex_geocode);
				})(stationData, geocode);
			}
			else {
				(function(ex_stationData, ex_geocode) {
					stationData.children('.label').one('click', function(){
						searchLibrary(ex_stationData, ex_geocode);
					});
				})(stationData, geocode);
			}
		})
	}

	function searchLibrary(ex_stationData, ex_geocode) {
		jQuery.getJSON('ajax/library?geocode='+ex_geocode, function(json) {
			for(var i=0; i<json.length; i++) {
				var library = json[i];
				var text = ''
				var name = library.name
				text += '<button type="button library" class="btn btn-success" title="'+ name+ '" >'
				text += '<span class="glyphicon glyphicon-book"></span><span>'+name+'</span>'
				text += '</button>'
				elm = jQuery(text);
				ex_stationData.next('div').children('.btn-group').append(elm);
				(function(url_pc){
					elm.click(function(){
						window.open(url_pc);
					})
				})(library.url_pc);
			}
		})
	};
})(findLiblary);


//イベントの割り当て
findLiblary.setIncrementalSearchAgent('.stationEntry');
findLiblary.attachSearchRoute('.search');
// findLiblary.attachSelectResult('.routeSelect')

// findLiblary.attachAndExecSearchLibrary()



