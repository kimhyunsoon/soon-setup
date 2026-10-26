#!/usr/bin/env python3
# 독립 StatusNotifierWatcher
# waybar tray가 watcher를 겸하면 waybar 재시작 시 등록 정보가 사라지고,
# Slack(Electron)처럼 재등록하지 않는 앱의 트레이 아이콘이 없어짐.
# 이 데몬이 이름을 먼저 선점하면 waybar는 host 역할만 하므로 재시작해도 아이콘 유지.

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

BUS_NAME = "org.kde.StatusNotifierWatcher"
OBJ_PATH = "/StatusNotifierWatcher"
IFACE_XML = """
<node>
  <interface name="org.kde.StatusNotifierWatcher">
    <method name="RegisterStatusNotifierItem"><arg name="service" type="s" direction="in"/></method>
    <method name="RegisterStatusNotifierHost"><arg name="service" type="s" direction="in"/></method>
    <property name="RegisteredStatusNotifierItems" type="as" access="read"/>
    <property name="IsStatusNotifierHostRegistered" type="b" access="read"/>
    <property name="ProtocolVersion" type="i" access="read"/>
    <signal name="StatusNotifierItemRegistered"><arg type="s"/></signal>
    <signal name="StatusNotifierItemUnregistered"><arg type="s"/></signal>
    <signal name="StatusNotifierHostRegistered"/>
    <signal name="StatusNotifierHostUnregistered"/>
  </interface>
</node>
"""
IFACE = Gio.DBusNodeInfo.new_for_xml(IFACE_XML).interfaces[0]

items = {}  # "bus/path" -> 감시 중인 bus name
hosts = set()
watch_ids = {}  # bus name -> watch id
conn = None


def emit(signal, args=None):
    conn.emit_signal(None, OBJ_PATH, IFACE.name, signal, args)


def emit_props_changed(names):
    props = {
        "RegisteredStatusNotifierItems": GLib.Variant("as", list(items)),
        "IsStatusNotifierHostRegistered": GLib.Variant("b", bool(hosts)),
    }
    changed = {n: props[n] for n in names}
    conn.emit_signal(
        None, OBJ_PATH, "org.freedesktop.DBus.Properties", "PropertiesChanged",
        GLib.Variant("(sa{sv}as)", (IFACE.name, changed, [])),
    )


def on_vanished(_conn, name):
    for item in [i for i, owner in items.items() if owner == name]:
        del items[item]
        emit("StatusNotifierItemUnregistered", GLib.Variant("(s)", (item,)))
        emit_props_changed(["RegisteredStatusNotifierItems"])
    if name in hosts:
        hosts.discard(name)
        if not hosts:
            emit("StatusNotifierHostUnregistered")
            emit_props_changed(["IsStatusNotifierHostRegistered"])
    Gio.bus_unwatch_name(watch_ids.pop(name))


def watch(name):
    if name not in watch_ids:
        watch_ids[name] = Gio.bus_watch_name_on_connection(
            conn, name, Gio.BusNameWatcherFlags.NONE, None, on_vanished
        )


def on_method_call(_conn, sender, _path, _iface, method, params, invocation):
    service = params.unpack()[0]
    if method == "RegisterStatusNotifierItem":
        # 경로만 넘기는 앱(Electron 등)은 sender 기준, bus name을 넘기면 기본 경로 사용
        if service.startswith("/"):
            bus, path = sender, service
        else:
            bus, path = service, "/StatusNotifierItem"
        item = bus + path
        invocation.return_value(None)
        if item not in items:
            items[item] = bus
            watch(bus)
            emit("StatusNotifierItemRegistered", GLib.Variant("(s)", (item,)))
            emit_props_changed(["RegisteredStatusNotifierItems"])
    elif method == "RegisterStatusNotifierHost":
        invocation.return_value(None)
        first = not hosts
        hosts.add(sender)
        watch(sender)
        if first:
            emit("StatusNotifierHostRegistered")
            emit_props_changed(["IsStatusNotifierHostRegistered"])


def on_get_property(_conn, _sender, _path, _iface, prop):
    if prop == "RegisteredStatusNotifierItems":
        return GLib.Variant("as", list(items))
    if prop == "IsStatusNotifierHostRegistered":
        return GLib.Variant("b", bool(hosts))
    if prop == "ProtocolVersion":
        return GLib.Variant("i", 0)
    return None


def on_bus_acquired(connection, _name):
    global conn
    conn = connection
    conn.register_object(OBJ_PATH, IFACE, on_method_call, on_get_property, None)


# ALLOW_REPLACEMENT 없이 소유 → waybar가 REPLACE로 요청해도 뺏기지 않음
# 이미 waybar가 소유 중이면 큐에서 대기하다 waybar가 죽을 때 넘겨받음
Gio.bus_own_name(
    Gio.BusType.SESSION, BUS_NAME, Gio.BusNameOwnerFlags.NONE,
    on_bus_acquired, None, None,
)
GLib.MainLoop().run()
