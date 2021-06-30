import sys
from os import environ
from jinja2 import Environment, PackageLoader, select_autoescape


def main():
  ca_cert_base64 = environ.get('CA_CRT_BASE64')
  client_cert_base64 = environ.get('CLIENT_CRT_BASE64')
  client_key_base64 = environ.get('CLIENT_KEY_BASE64')

  if not (ca_cert_base64 and client_cert_base64 and client_key_base64):
    print(
      'missing some environment variables for CA_CRT_BASE64, CLIENT_CRT_BASE64, and/or CLIENT_KEY_BASE64',
      file=sys.stderr
    )
    raise AssertionError('not all required environment variables are set.')

  template_data = {
    'ca_cert_base64': ca_cert_base64,
    'client_cert_base64': client_cert_base64,
    'client_key_base64': client_key_base64
  }

  env = Environment(
    loader=PackageLoader("rpi_k8s"),
    autoescape=select_autoescape()
  )

  rendered_template = env.get_template('user_config.yaml').render(**template_data)
  print(rendered_template)


if __name__ == '__main__':
    main()