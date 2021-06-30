from setuptools import setup, find_packages

setup(
  name='rpi_k8s',
  version='1.0',
  packages=find_packages(),
  entry_points={
    'console_scripts': ['build-user-config=rpi_k8s.build_user_config:main'],
  }
)