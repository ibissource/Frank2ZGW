/*
   Copyright 2013 Nationale-Nederlanden, 2021 WeAreFrank!

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
package org.frankframework.util;

import org.frankframework.core.IbisException;

public class DomBuilderException extends IbisException {

	public DomBuilderException() {
		super();
	}

	public DomBuilderException(String msg) {
		super(msg);
	}

	public DomBuilderException(String msg, Throwable nestedException) {
		super(msg, nestedException);
	}

	public DomBuilderException(Throwable nestedException) {
		super(nestedException);
	}
}
