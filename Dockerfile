FROM frappe/bench:latest
WORKDIR /home/frappe
COPY init.sh /workspace/init.sh
RUN chmod +x /workspace/init.sh
CMD ["bash", "/workspace/init.sh"]
