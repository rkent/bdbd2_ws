# Demo of launching, using the talker node.

from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        Node(
            package='demo_nodes_cpp',
            namespace='test_namespace',
            executable='talker',
            name='test_name'
        ),
    ])
