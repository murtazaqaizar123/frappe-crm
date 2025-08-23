FROM frappe/bench:latest
WORKDIR /home/frappe

# Copy script into container
COPY init.sh /workspace/init.sh

# Make it executable during build (not inside Coolify runtime)
RUN chmod +x /workspace/init.sh

# Run script as startup command
CMD ["bash", "/workspace/init.sh"]
