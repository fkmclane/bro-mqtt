##! Implements base functionality for MQTT analysis.
##! Generates the Mqtt.log file.

module Mqtt;

@load ./consts.bro

export {
	redef enum Log::ID += { LOG };

	type Info: record {
		## Timestamp for when the event happened.
		ts:     time    &log;
		## Unique ID for the connection.
		uid:    string  &log;
		## The connection's 4-tuple of endpoint addresses/ports.
		id:     conn_id &log;

		msg_type: string &log;

		pname:  string  &log;

		pversion: count &log;

		cid: string &log;
		
		return_code: string &log;

		msg_id: count &log;

		topic: string &log;

		QoS: count &log;
	};

	## Event that can be handled to access the MQTT record as it is sent on
	## to the loggin framework.
	global log_mqtt: event(rec: Info);
}

# TODO: The recommended method to do dynamic protocol detection
# (DPD) is with the signatures in dpd.sig. If you can't come up
# with any signatures, then you can do port-based detection by
# uncommenting the following and specifying the port(s):

const ports = { 1883/tcp };

redef likely_server_ports += { ports };

event bro_init() &priority=5
	{
	Log::create_stream(Mqtt::LOG, [$columns=Info, $ev=log_mqtt, $path="mqtt"]);

	# TODO: If you're using port-based DPD, uncomment this.
	Analyzer::register_for_ports(Analyzer::ANALYZER_MQTT, ports);
	}

event mqtt_conn(c: connection, msg_type: count, protocol_name: string, protocol_version: count, client_id: string)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$pname = protocol_name;
	info$pversion = protocol_version;
	info$cid = client_id;

	Log::write(Mqtt::LOG, info);
	}

event mqtt_connack(c: connection, msg_type: count, return_code: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$return_code = return_codes[return_code];

	Log::write(Mqtt::LOG, info);
	}

event mqtt_pub(c: connection, msg_type: count, msg_id: count, topic: string)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$msg_id = msg_id;
	info$topic = topic;

	Log::write(Mqtt::LOG, info);
	}

event mqtt_puback(c: connection, msg_type: count, msg_id: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$msg_id = msg_id;

	Log::write(Mqtt::LOG, info);
	}

event mqtt_sub(c: connection, msg_type: count, msg_id: count, subscribe_topic: string, requested_QoS: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$msg_id = msg_id;
	info$topic = subscribe_topic;
	info$QoS = requested_QoS;

	Log::write(Mqtt::LOG, info);
	}

event mqtt_suback(c: connection, msg_type: count, msg_id: count, granted_QoS: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$msg_id = msg_id;
	info$QoS = granted_QoS;

	Log::write(Mqtt::LOG, info);
	}

event mqtt_unsub(c: connection, msg_type: count, msg_id: count, unsubscribe_topic: string)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$msg_id = msg_id;
	info$topic = unsubscribe_topic;

	Log::write(Mqtt::LOG, info);
	}

event mqtt_unsuback(c: connection, msg_type: count, msg_id: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];
	info$msg_id = msg_id;

	Log::write(Mqtt::LOG, info);
	}

event mqtt_pingreq(c: connection, msg_type: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];

	Log::write(Mqtt::LOG, info);
	}

event mqtt_pingres(c: connection, msg_type: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];

	Log::write(Mqtt::LOG, info);
	}

event mqtt_disconnect(c: connection, msg_type: count)
	{
	local info: Info;
	info$ts  = network_time();
	info$uid = c$uid;
	info$id  = c$id;
	info$msg_type = msg_types[msg_type];

	Log::write(Mqtt::LOG, info);
	}

