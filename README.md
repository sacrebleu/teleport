# Teleport

Author: Jeremy Botha
Version: 0.0.1

#### Overview

Teleport is a facade in front of the whatsapp business api's token-based authentication, it proxies this so that systems such as Prometheus can still access metrics without requiring credentials, which are configured in a file-based database.

To Do:

* Persistence of credentials - mysql database
