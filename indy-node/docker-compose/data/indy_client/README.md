# Indy CLI

> Note: Remember to execute `make-all` command to build the image.

Prepare the local folder for storing `indy-cli` data by executing the following commands:

```
sudo chown -R 1000:root data/indy_client
```

```
chmod -R ug+rw data/indy_client
```

Execute the following command from `docker-compose` folder to run `indy-cli`.

```
docker run -v ./data/indy_client:/home/indy/.indy_client --rm -it nordxdataspace/indy_cli indy-cli
```
