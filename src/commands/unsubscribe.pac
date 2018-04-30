refine casetype Command += {
	MQTT_UNSUBSCRIBE -> unsubscribe : MQTT_unsubscribe;
};

type MQTT_unsubscribe = record {
	msg_id : uint16;
	topics : MQTT_string[];
} &let {
	proc: bool = $context.flow.proc_mqtt_unsubscribe(this);
};

refine flow MQTT_Flow += {
	function proc_mqtt_unsubscribe(msg: MQTT_unsubscribe): bool
		%{
		if ( mqtt_unsubscribe )
			{
			StringVal* unsubscribe_topic = 0;

			for (auto topic: *${msg.topics})
				{
				unsubscribe_topic = new StringVal(${topic.str}.length(),
				                                  (const char*) ${topic.str}.begin());
				}

			BifEvent::generate_mqtt_unsubscribe(connection()->bro_analyzer(), 
			                                    connection()->bro_analyzer()->Conn(),
			                                    ${msg.msg_id},
			                                    unsubscribe_topic);
			}

		return true;
		%}
};
