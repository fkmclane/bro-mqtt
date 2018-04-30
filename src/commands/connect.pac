refine casetype Command += {
	MQTT_CONNECT -> connect : MQTT_connect;
};

type MQTT_will = record {
	topic : MQTT_string;
	msg   : MQTT_string;
};

type MQTT_connect = record {
	protocol_name    : MQTT_string;
	protocol_version : int8;
	connect_flags    : uint8;
	keep_alive       : uint16;
	client_id        : MQTT_string;

	# payload starts
	will_fields: case will_flag of {
		true  -> will     : MQTT_will;
		false -> nofield1 : empty;
	};
	username_fields: case username of {
		true  -> uname    : MQTT_string;
		false -> nofield2 : empty;
	};
	password_fields: case password of {
		true  -> pass     : MQTT_string;
		false -> nofield3 : empty;
	};
} &let {
	username      : bool  = (connect_flags & 0x80) != 0;
	password      : bool  = (connect_flags & 0x40) != 0;
	will_retain   : bool  = (connect_flags & 0x20) != 0;
	will_qos      : uint8 = (connect_flags & 0x18) >> 3;
	will_flag     : bool  = (connect_flags & 0x04) != 0;
	clean_session : bool  = (connect_flags & 0x02) != 0;

	proc: bool = $context.flow.proc_mqtt_connect(this);
};


refine flow MQTT_Flow += {
	function proc_mqtt_connect(msg: MQTT_connect): bool
		%{
		if ( mqtt_connect )
			{
			auto m = new RecordVal(BifType::Record::MQTT::ConnectMsg);
			m->Assign(0, new StringVal(${msg.protocol_name.str}.length(),
			                           (const char*) ${msg.protocol_name.str}.begin()));
			m->Assign(1, new Val(${msg.protocol_version}, TYPE_COUNT));
			m->Assign(2, new StringVal(${msg.client_id.str}.length(),
			                           (const char*) ${msg.client_id.str}.begin()));
			m->Assign(3, new Val(${msg.keep_alive}, TYPE_COUNT));

			m->Assign(4, new Val(${msg.will_retain}, TYPE_BOOL));
			m->Assign(5, new Val(${msg.will_qos}, TYPE_COUNT));

			if ( ${msg.will_flag} )
				{
				m->Assign(6, new StringVal(${msg.will.topic.str}.length(),
				                             (const char*) ${msg.will.topic.str}.begin()));
				m->Assign(7, new StringVal(${msg.will.msg.str}.length(),
				                             (const char*) ${msg.will.msg.str}.begin()));
				}

			if ( ${msg.username} )
				{
				m->Assign(8, new StringVal(${msg.uname.str}.length(),
				                           (const char*) ${msg.uname.str}.begin()));
				}
			if ( ${msg.password} )
				{
				m->Assign(9, new StringVal(${msg.pass.str}.length(),
				                           (const char*) ${msg.pass.str}.begin()));
				}

			BifEvent::generate_mqtt_connect(connection()->bro_analyzer(),
			                                connection()->bro_analyzer()->Conn(),
			                                m);
			}

		// If a connect message was seen, let's say that confirms it.
		connection()->bro_analyzer()->ProtocolConfirmation();
		return true;
		%}
};
