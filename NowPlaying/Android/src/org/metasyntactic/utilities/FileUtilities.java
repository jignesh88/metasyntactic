//Copyright 2008 Cyrus Najmabadi
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

package org.metasyntactic.utilities;

import org.joda.time.DateTime;
import org.joda.time.Days;
import org.metasyntactic.Constants;

import java.io.*;

/** @author cyrusn@google.com (Cyrus Najmabadi) */
public class FileUtilities {
	private FileUtilities() {

	}

	public static String sanitizeFileName(String name) {
		StringBuilder result = new StringBuilder();
		for (char c : name.toCharArray()) {
			if ((c >= 'a' && c <= 'z') ||
				  (c >= 'A' && c <= 'Z') ||
				  (c >= '0' && c <= '9')) {
				result.append(c);
			} else {
				result.append("-" + (int)c + "-");
			}
		}
		return result.toString();
	}

	public static void writeObject(Object o, String fileName) {
		writeObject(o, new File(fileName));
	}

	public static void writeObject(Object o, File file) {
		try {
			ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream(file));
			out.writeObject(o);
			out.flush();
			out.close();
		} catch (IOException e) {
			ExceptionUtilities.log(FileUtilities.class, "writeObject", e);
			throw new RuntimeException(e);
		}
	}

	public static <T> T readObject(String fileName) {
		return (T) readObject(new File(fileName));
	}

	public static <T> T readObject(File file) {
		try {
			if (!file.exists()) {
				return null;
			}

			ObjectInputStream in = new ObjectInputStream(new FileInputStream(file));
			T result = (T) in.readObject();
			in.close();
			return result;
		} catch (IOException e) {
			ExceptionUtilities.log(FileUtilities.class, "readObject", e);
			return null;
		} catch (ClassNotFoundException e) {
			ExceptionUtilities.log(FileUtilities.class, "readObject", e);
			throw new RuntimeException(e);
		}
	}

	public static boolean tooSoon(String fileName) {
		File file = new File(fileName);
		if (!file.exists()) {
			return false;
		}

		DateTime now = new DateTime();
		DateTime lastDate = new DateTime(file.lastModified());

		int days = Days.daysBetween(now, lastDate).getDays();
		if (days > 0) {
			// different days, so definitely out of date
			return false;
		}

		long hours = (now.getMillis() - lastDate.getMillis()) / Constants.ONE_HOUR;
		if (hours > 8) {
			return false;
		}

		return true;
	}
}
