FROM frappe/bench:latest
WORKDIR /home/frappe

COPY init.sh /workspace/init.sh

# No chmod needed, just call with bash
CMD ["bash", "/workspace/init.sh"]
