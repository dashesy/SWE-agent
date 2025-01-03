FROM python:3.11

RUN python3 -m pip install pipx && python3 -m pipx ensurepath --global
