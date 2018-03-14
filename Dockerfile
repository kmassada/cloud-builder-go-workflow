FROM scratch
ADD main /
CMD chmod +x /main
CMD ["/main"]