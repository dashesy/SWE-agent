FROM ubuntu:20.04

# Install third party tools
RUN apt-get update && \
    apt-get install -y bash gcc git jq wget curl g++ make vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Install nodejs
# RUN apt update && \
#     apt install -y nodejs npm && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# Initialize git
RUN git config --global user.email "ehazar@microsoft.com"
RUN git config --global user.name "ehazar"

# Install miniconda
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
COPY docker/getconda.sh .
RUN bash getconda.sh amd64 \
    && rm getconda.sh \
    && mkdir /root/.conda \
    && bash miniconda.sh -b \
    && rm -f miniconda.sh
RUN conda --version \
    && conda init bash \
    && conda config --append channels conda-forge

# Install Docker CLI using the official Docker installation script
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh

RUN conda create -y -n swed python=3.12
RUN echo ". /root/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate swed" >> ~/.bashrc

RUN mkdir /root/deps

# Install python packages
COPY docker/requirements.txt /root/requirements.txt
RUN . /root/miniconda3/etc/profile.d/conda.sh && conda activate swed\
    && pip install -r /root/requirements.txt

# Extras
RUN . /root/miniconda3/etc/profile.d/conda.sh && conda activate swed\
&& pip install ipython

# If need local changes
# RUN mkdir /root/swe-rex
# COPY swe-rex /root/swe-rex
# RUN pip install -e /root/swe-rex

WORKDIR /SWE-agent

# Copy the application code
# Do this last to take advantage of the docker layer mechanism
COPY . /SWE-agent

# Install Python dependencies
RUN . /root/miniconda3/etc/profile.d/conda.sh && conda activate swed\
    && pip install -e '.'


#  Cache datasets
RUN . /root/miniconda3/etc/profile.d/conda.sh && conda activate swed\
    && python swed_init.py


# # Install react dependencies ahead of time
# RUN cd sweagent/frontend && npm install

CMD ["/bin/bash"]
