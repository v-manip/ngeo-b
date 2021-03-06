
from ngeo_browse_server.control.control.config import (
    get_instance_id, CONTROLLER_SERVER_SECTION
)


class ControllerAssertionError(AssertionError):
    def __init__(self, message, reason):
        super(ControllerAssertionError, self).__init__(message)
        self.reason = reason


def assert_instance_id(instance_id, config):
    actual_instance_id = get_instance_id(config)

    if instance_id != actual_instance_id:
        raise ControllerAssertionError(
            "The provided instance ID (%s) is not the same as the configured "
            "one (%s)." % (instance_id, actual_instance_id),
            reason="INSTANCE_OTHER"
        )


def assert_instance_type(instance_type):
    if instance_type != "BrowseServer":
        raise ControllerAssertionError(
            "The provided instance type '%s' is not 'BrowseServer'." % 
            (instance_type), reason="TYPE_OTHER"
        )


def assert_controller_id(cs_id, controller_config, reason):
    actual_id = controller_config.get(CONTROLLER_SERVER_SECTION, "identifier")

    if actual_id != cs_id:
        raise ControllerAssertionError(
            "This browse server instance is registered on the "
            "controller server with ID '%s'." % (actual_id),
            reason=reason # because its currently different in register/unregister
        )


def assert_controller_ip(cs_ip, controller_config):
    actual_ip = controller_config.get(CONTROLLER_SERVER_SECTION, "address")

    if actual_ip != cs_ip:
        raise ControllerAssertionError(
            "This browse server instance is registered on a "
            "controller server with the same ID but another "
            "IP-address ('%s')." % actual_ip,
            reason="INTERFACE_OTHER"
        )
