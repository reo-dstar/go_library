
var findLiblary = findLiblary || {};


(function (findLiblary){
	var incrementalSearchInterval = 2000;

	findLiblary.setIncrementalSearchAgent = function(selecter) {
		var interval = 2000;
		jQuery(selecter).each(function() {
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
					for each (var station in json) {
						text += '<option value='+station.code+'>'+station.name+'</option>';
					}
				 	_target.nextAll('.stationSelectBox').empty().append(text).show().focus();
				})
			}
			var target = jQuery(this);
			var old = target.val();
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


	findLiblary.attachSetStation = function(selecter) {
		jQuery(selecter).keypress( function ( e ) {
			if ( e.which == 13 ) {
				var stationListBox = jQuery(this);
				var station_tgt = stationListBox.prevAll('.stationEntry')
				station_tgt.val(jQuery(this).find('option:selected').text());
				stationListBox.closest('.inputrow').next('.inputrow').find('.stationEntry').focus();
				stationListBox.hide();
			}
		});
	}

	findLiblary.attachSearchRoute = function(selecter) {
		jQuery(selecter).click(function(){
			var stationList = [];
			jQuery('.stationEntry').each(function () {
				var val = jQuery(this).val();
				if (val) {
					stationList.push(val);
				}
			})
			var viaList = stationList.join(':');
			window.location.href = "/search?viaList=" + viaList;
		});
	}

	findLiblary.attachSelectResult = function(selecter) {
		jQuery(selecter).click(function(){
			serializeData = jQuery(this).nextAll('input').val();
			window.location.href = "/result?serializeData=" + serializeData;
		})
	}


	function searchLibrary(ex_stationData, ex_geocode) {
		jQuery.getJSON('ajax/library?geocode='+ex_geocode, function(json) {
			for each (var library in json) {
				var text = ''
				var name = library.name
				text += '<button type="button library" class="btn btn-success" title="'+ name+ '" >'
				text += '<span class="glyphicon glyphicon-book"></span><span>'+name+'</span>'
				text += '</button>'
				elm = jQuery(text);
				// ex_stationData.next('div').children('.btn-group').append(text);				
				ex_stationData.next('div').children('.btn-group').append(elm);
				
				elm.click(function(){
					window.location.href = library.url_pc;
				})
			}
		})
	};


	findLiblary.attachAndExecSearchLibrary = function() {
		jQuery('.station-data').each(function(){
			stationData = jQuery(this);
			geocode = stationData.find('.geocode').val();
			primary = stationData.find('.primary').val();
			if (primary == 'true') {
				(function(ex_stationData, ex_geocode) {
					searchLibrary(ex_stationData, ex_geocode);
					// jQuery.getJSON('ajax/library?geocode='+ex_geocode, function(json) {
					// 	var text = ''
					// 	for each (var library in json) {
					// 		var name = library.name
					// 		text += '<button type="button library" class="btn btn-success" title="'+ name+ '" >'
					// 		text += '<span class="glyphicon glyphicon-book"></span><span>'+name+'</span>'
					// 		text += '</button>'
					// 	}
					// 	ex_stationData.next('div').children('.btn-group').append(text)
					// })
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

})(findLiblary);


//イベントの割り当て
findLiblary.setIncrementalSearchAgent('.stationEntry');
findLiblary.attachSetStation('.stationSelectBox');
findLiblary.attachSearchRoute('.search');
findLiblary.attachSelectResult('.routeSelect')

findLiblary.attachAndExecSearchLibrary()



